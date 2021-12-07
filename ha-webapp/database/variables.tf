variable "ami" {
  type = string 
  default = "ami-0a49b025fffbbdac6" # free tier ubuntu 20.04 / region eu-central-1
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

