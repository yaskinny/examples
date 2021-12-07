output "pubip" {
  description = "bastion public ip"
  value = aws_eip.eip.public_ip
}
