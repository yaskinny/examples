locals {
  vpc_cidr = "192.168.0.0/16"
  internet = "0.0.0.0/0"
  p = "webapp"
}



# create vpc
resource "aws_vpc" "vpc" {
  cidr_block = local.vpc_cidr
  instance_tenancy = "default"
  tags = {
    project = local.p
  }
}


# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# add route for igw in default route table
resource "aws_route" "igw-r" {
  route_table_id = aws_vpc.vpc.default_route_table_id
  destination_cidr_block = local.internet
  gateway_id = aws_internet_gateway.igw.id
}


# get list of AZs
data "aws_availability_zones" "azs" {
  state = "available"
}

# create subnets
# 1x public for bastion
# 1x public for NAT gateway
# 1x private for DBS
# 2x (diff AZs) for webapp

resource "aws_subnet" "subs" {
  for_each = { for k, v in var.subnets: k => v }
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(local.vpc_cidr,8,each.key)
  map_public_ip_on_launch = each.value.pub_ip
  availability_zone = data.aws_availability_zones.azs.names[each.value.az]
  tags = {
    "for" = each.value.f
    project = local.p
  }
}

# create route table for private subnets
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = local.internet
    gateway_id = values(aws_nat_gateway.ng)[0].id
  }
}

# associate route table to private subnets
resource "aws_route_table_association" "rts" {
  for_each = { for k, v in aws_subnet.subs: k => v if v.map_public_ip_on_launch == false }
  subnet_id = each.value.id
  route_table_id = aws_route_table.rt.id
}

# create EIP for NAT gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# create NAT gateway
resource "aws_nat_gateway" "ng" {
  for_each = { for k, v in aws_subnet.subs: k => v if v.tags.for == "nat" }
  subnet_id = each.value.id
  allocation_id = aws_eip.nat_eip.id
}
