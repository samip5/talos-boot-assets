data "aws_region" "current" {}

data "aws_ec2_managed_prefix_list" "ec2_instance_connect" {
  name = "com.amazonaws.${data.aws_region.current.name}.ec2-instance-connect"
}

resource "aws_security_group" "buildkit" {
  name        = "buildkit"
  description = "Security group for buildkit instance"
  vpc_id      = var.vpc_id

  tags = {
    Name = "buildkit"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ts_builkit_v4" {
  security_group_id = aws_security_group.buildkit.id

  cidr_ipv4   = "100.64.0.0/10"
  from_port   = 9999
  ip_protocol = "tcp"
  to_port     = 9999
}

resource "aws_vpc_security_group_ingress_rule" "ts_builkit_v6" {
  security_group_id = aws_security_group.buildkit.id

  cidr_ipv6   = "fd7a:115c:a1e0::/48"
  from_port   = 9999
  ip_protocol = "tcp"
  to_port     = 9999
}

resource "aws_vpc_security_group_ingress_rule" "ts_ssh_v4" {
  security_group_id = aws_security_group.buildkit.id

  cidr_ipv4   = "100.64.0.0/10"
  cidr_ipv6   = "fd7a:115c:a1e0::/48"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "ts_ssh_v6" {
  security_group_id = aws_security_group.buildkit.id

  cidr_ipv6   = "fd7a:115c:a1e0::/48"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ic_ssh" {
  security_group_id = aws_security_group.buildkit.id

  from_port      = 22
  ip_protocol    = "tcp"
  prefix_list_id = data.aws_ec2_managed_prefix_list.ec2_instance_connect.id
  to_port        = 22
}

resource "aws_vpc_security_group_egress_rule" "all_v4" {
  security_group_id = aws_security_group.buildkit.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "all_v6" {
  security_group_id = aws_security_group.buildkit.id
  cidr_ipv4         = "::/0"
  ip_protocol       = "-1"
}
