variable "region" {
  type = string
  default = "eu-central-1"
}
variable "vpc_id" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "source_ami" {
  type = string
  default = "ami-0a49b025fffbbdac6" # ubuntu 20-04 free tier
}
variable "instance_type" {
  type = string
  default = "t2.micro"
}
variable "version" {
  type = string
  default = "latest"
}
