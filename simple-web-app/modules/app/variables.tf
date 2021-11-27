variable "ami" {
  type = string
  default = "ami-0a49b025fffbbdac6" # free tier ubuntu 20.04 
}
variable "instance_type" {
  type = string
  default = "t2.micro" # free tier
}

variable "pub_subnet_id" {
  description = "public subnet"
  type = string
}

variable "prv_subnet_id" {
  description = "private subnet"
  type = string
}

variable "local_pub_ip" {
  description = "ip for ssh sg"
  type = string
}

variable "ssh_pubkey_path" {
  description = "path to ssh public key"
  type = string
}

variable "ssh_privkey_path" {
  description = "path to ssh private key"
  type = string
}

variable "vpc_id" {
  description = "vpc id for sg"
  type = string 
}
