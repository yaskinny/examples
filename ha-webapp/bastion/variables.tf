variable "pubip" {
  type = string
}

variable "bastion_pubkey_path" {
  type = string
}
variable "instance_pubkey_path" {
  type = string
}

variable "ami" {
  type = string
  default = "ami-0a49b025fffbbdac6"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

