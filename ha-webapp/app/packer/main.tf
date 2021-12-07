terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
  profile = "default"
}

data "aws_vpc" "vpc" {
  filter { 
    name = "tag:project"
    values = ["webapp"]
  }
}

data "aws_subnet" "sub" {
  filter {
    name = "tag:for"
    values = ["public"]
  }
}

resource "null_resource" "this" {
  provisioner "local-exec" {
    command = "./runme.sh Subnet.${data.aws_subnet.sub.id} Vpc.${data.aws_vpc.vpc.id}"
  }
}
