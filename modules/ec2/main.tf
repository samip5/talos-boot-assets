resource "random_shuffle" "subnet_ids" {
  input        = var.subnet_ids
  result_count = 1
}

data "aws_ami" "buildkit-amd64" {
  most_recent = true
  filter {
    name   = "name"
    values = ["buildkit-amd64-*"]
  }
  owners = ["992382661722"]
}

data "aws_ami" "buildkit-arm64" {
  most_recent = true
  filter {
    name   = "name"
    values = ["buildkit-arm64-*"]
  }
  owners = ["992382661722"]
}

resource "aws_instance" "buildkit-amd64" {
  count         = 1
  ami           = data.aws_ami.buildkit-amd64.id
  instance_type = "c5a.4xlarge"
  instance_market_options {
    market_type = "spot"
  }

  associate_public_ip_address = true

  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile
  subnet_id              = random_shuffle.subnet_ids.result[0]

  root_block_device {
    volume_type = "gp3"
    volume_size = 80
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e
    tailscale up --authkey ${var.ts_auth_key_amd64} --ssh
  EOF

  tags = {
    Name = "buildkit-amd64"
  }
}

resource "aws_instance" "buildkit-arm64" {
  count         = 1
  ami           = data.aws_ami.buildkit-arm64.id
  instance_type = "c6g.4xlarge"
  instance_market_options {
    market_type = "spot"
  }

  associate_public_ip_address = true

  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile
  subnet_id              = random_shuffle.subnet_ids.result[0]

  root_block_device {
    volume_type = "gp3"
    volume_size = 80
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e
    tailscale up --authkey ${var.ts_auth_key_arm64} --ssh
  EOF

  tags = {
    Name = "buildkit-arm64"
  }
}
