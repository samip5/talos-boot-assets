packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-west-2"
}

# Common builder configuration
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  common_tags = {
    Created     = local.timestamp
    Environment = "production"
    Name        = "buildkit"
  }
}

# amd64 Builder
source "amazon-ebs" "buildkit-amd64" {
  ami_name      = "buildkit-amd64-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.region
  source_ami    = "ami-055e3d4f0bbeb5878" # Amazon Linux 2023 amd64
  ssh_username  = "ec2-user"
  tags          = merge(local.common_tags, { Architecture = "amd64" })
}

# arm64 Builder
source "amazon-ebs" "buildkit-arm64" {
  ami_name      = "buildkit-arm64-${local.timestamp}"
  instance_type = "t4g.micro"
  region        = var.region
  source_ami    = "ami-01167b661200e49e7" # Amazon Linux 2023 arm64
  ssh_username  = "ec2-user"
  tags          = merge(local.common_tags, { Architecture = "arm64" })
}

# Build configuration
build {
  sources = [
    "source.amazon-ebs.buildkit-amd64",
    "source.amazon-ebs.buildkit-arm64"
  ]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker git",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ec2-user"
    ]
  }

  provisioner "shell" {
    inline = [
      "BUILDKIT_VERSION=0.18.1",
      "ARCH=$(uname -m)",
      "if [ \"$ARCH\" = \"amd64\" ]; then",
      "  BUILDKIT_FILE=\"buildkit-v$BUILDKIT_VERSION.linux-amd64.tar.gz\"",
      "else",
      "  BUILDKIT_FILE=\"buildkit-v$BUILDKIT_VERSION.linux-arm64.tar.gz\"",
      "fi",
      "sudo curl -sSL \"https://github.com/moby/buildkit/releases/download/v$BUILDKIT_VERSION/$BUILDKIT_FILE\" -o buildkit.tar.gz",
      "sudo tar -xzf buildkit.tar.gz -C /usr/local/bin --strip-components=1"
    ]
  }

  provisioner "shell" {
    inline = [
      "curl -fsSL https://tailscale.com/install.sh | sudo sh"
    ]
  }

  provisioner "file" {
    content     = <<EOF
[Unit]
Description=BuildKit daemon
After=network.target

[Service]
ExecStart=/usr/local/bin/buildkitd --addr tcp://0.0.0.0:9999 --addr unix:///run/buildkit/buildkitd.sock --debug
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    destination = "/tmp/buildkitd.service"
  }

  provisioner "file" {
    content     = <<EOF
[worker.oci]
  gc = true
  gckeepstorage = 50000

  [[worker.oci.gcpolicy]]
    keepBytes = 10737418240
    keepDuration = 604800
    filters = [ "type==source.local", "type==exec.cachemount", "type==source.git.checkout"]
  [[worker.oci.gcpolicy]]
    all = true
    keepBytes = 53687091200
EOF
    destination = "/tmp/buildkitd.toml"
  }

  provisioner "file" {
    content     = <<EOF
PORT="41641"
FLAGS="-state mem:"
EOF
    destination = "/tmp/tailscaled"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/tailscaled /etc/default/tailscaled",
      "sudo mkdir -p /etc/buildkit",
      "sudo mv /tmp/buildkitd.toml /etc/buildkit/buildkitd.toml",
      "sudo mv /tmp/buildkitd.service /etc/systemd/system/buildkitd.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable buildkitd"
    ]
  }
}
