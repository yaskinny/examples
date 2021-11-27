output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "pub_subnet_id" {
  value = aws_subnet.pub_subnet.id
}

output "prv_subnet_id" {
  value = aws_subnet.prv_subnet.id
}
