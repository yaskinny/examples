locals {
  vpc_cidr = "192.168.0.0/16"
  internet_cidr = "0.0.0.0/0"
  internet_cidr_6 = "::/0"
}
resource "aws_vpc" "my_vpc" {
  cidr_block       = local.vpc_cidr
  instance_tenancy = "default"
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_eip" "nat_eip" {
  vpc = true 
}

resource "aws_route" "my_route" {
  route_table_id         = aws_vpc.my_vpc.default_route_table_id
  gateway_id             = aws_internet_gateway.my_igw.id
  destination_cidr_block = local.internet_cidr
}

resource "aws_subnet" "pub_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, 1)
  map_public_ip_on_launch = true
}

resource "aws_subnet" "prv_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, 2)
  map_public_ip_on_launch = false
}

resource "aws_subnet" "nat_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, 3)
  map_public_ip_on_launch = false
}

resource "aws_nat_gateway" "pub_gw" {
  allocation_id = aws_eip.nat_eip.id
  connectivity_type = "public"
  subnet_id = aws_subnet.nat_subnet.id
  depends_on = [
    aws_internet_gateway.my_igw,
  ]
}

resource "aws_route_table" "prv_subnet_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = local.internet_cidr
    gateway_id = aws_nat_gateway.pub_gw.id
  }
}

resource "aws_route_table_association" "prv_subnet_r" {
  subnet_id = aws_subnet.prv_subnet.id
  route_table_id = aws_route_table.prv_subnet_rt.id
}

