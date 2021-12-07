locals {
  internet = "0.0.0.0/0"
}
data "aws_vpc" "vpc" {
  filter {
    name = "tag:project"
    values = ["webapp"]
  }
}

data "aws_subnet" "sub" {
  filter {
    name = "tag:project"
    values = ["webapp"]
  }
  filter {
    name = "tag:for"
    values = ["db"]
  }
}

data "aws_instance" "bastion" {
  filter {
    name = "tag:role"
    values = ["bastion"]
  }
}

data "aws_subnets" "apps" {
  filter {
    name = "tag:for"
    values = ["app"]
  }
}

data "aws_subnet" "app_subnets" {
  for_each = toset([for v in data.aws_subnets.apps.ids: v])
  id = each.value
}

# create sg
resource "aws_security_group" "sg" {
  name = "redis"
  description = "SG for redis instance"
  vpc_id = data.aws_vpc.vpc.id
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${data.aws_instance.bastion.private_ip}/32"]
  }

  ingress { ### get ips of app subnets
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = values(data.aws_subnet.app_subnets)[*].cidr_block
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [local.internet]
  }
}

# create
resource "aws_instance" "redis" {
  ami = var.ami
  instance_type = var.instance_type
  # since there is no SD, setting IP manually so can set it manually for apps too
  private_ip = "192.168.3.100"
  subnet_id = data.aws_subnet.sub.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name = "instances"
}
