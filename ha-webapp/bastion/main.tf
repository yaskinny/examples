locals {
  kn = "bastion"
  internet = "0.0.0.0/0"
}
 
# vpc
data "aws_vpc" "vpc" {
  filter {
    name = "tag:project"
    values = ["webapp"]
  }
}

# subnet
data "aws_subnet" "sub" {
  filter {
    name = "tag:for"
    values = ["public"]
  }
}

# create EIP for bastion
resource "aws_eip" "eip" {
  vpc = true
  instance = aws_instance.bastion.id
}

# create SG
resource "aws_security_group" "sg" {
  name = "bastion"
  vpc_id = data.aws_vpc.vpc.id
  description = "bastion"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.pubip}/32"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["${var.pubip}/32"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [local.internet]
  }
}


# create ssh key pair for bastion and other hosts
resource "aws_key_pair" "kp" {
  key_name = local.kn
  public_key = file(var.bastion_pubkey_path)
}

resource "aws_key_pair" "kp_instances" {
  key_name = "instances"
  public_key = file(var.instance_pubkey_path)
}

resource "aws_instance" "bastion" {
  ami = var.ami
  key_name = local.kn
  instance_type = var.instance_type
  subnet_id = data.aws_subnet.sub.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    role = local.kn
  }
}
