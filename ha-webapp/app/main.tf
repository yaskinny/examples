locals {
  internet = "0.0.0.0/0"
}

data "aws_subnets" "subs" {
  filter {
    name = "tag:project"
    values = ["webapp"]
  }
  filter {
    name = "tag:for"
    values = ["app"]
  }
}

data "aws_subnets" "lb_sub" {
  filter {
    name = "tag:for"
    values = ["lb"]
  }
}

data "aws_instance" "bastion" {
  filter {
    name = "tag:role"
    values = ["bastion"]
  }
}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:project"
    values = ["webapp"]
  }
}

data "aws_subnet" "app_subs" {
  for_each = toset([for v in data.aws_subnets.subs.ids: v])
  id = each.value
}

# find latest webapp ami id
data "aws_ami" "webapp" {
  owners = ["self"]
  most_recent = true
  filter {
    name = "name"
    values = ["webapp-*"]
  }
}


# create sg for webapp lt
resource "aws_security_group" "lt_sg" {
  name = "webapp"
  description = "SG for webapp LT"
  vpc_id = data.aws_vpc.vpc.id
  
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [local.internet]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${data.aws_instance.bastion.private_ip}/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [local.internet]
  }
}

# create SG for ALB
resource "aws_security_group" "lb_sg" {
  name = "webapp_lb"
  description = "SG for webapp ALB"
  vpc_id = data.aws_vpc.vpc.id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [local.internet]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [local.internet]
  }
}

# create launch template
resource "aws_launch_template" "lt" {
  name = "webapp"
  description = "template for webapp ASG"
  image_id = data.aws_ami.webapp.id
  instance_type = var.instance_type
  key_name = "instances"
  vpc_security_group_ids = [aws_security_group.lt_sg.id]
}

# create TG
resource "aws_lb_target_group" "tg" {
  port = 8080
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = data.aws_vpc.vpc.id
}

# create ALB
resource "aws_lb" "lb" {
  load_balancer_type = "application"
  name = "webapp-lb"
  security_groups = [aws_security_group.lb_sg.id]
  subnets = data.aws_subnets.lb_sub.ids
  internal = false
}

# set listener for lb
resource "aws_lb_listener" "r" {
  load_balancer_arn = aws_lb.lb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# create ASG
resource "aws_autoscaling_group" "webapp" {
  name = "webapp"
  vpc_zone_identifier = values(data.aws_subnet.app_subs)[*].id
  max_size = 4
  min_size = 2
  desired_capacity = 3
  launch_template { 
    id = aws_launch_template.lt.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.tg.arn]
}
