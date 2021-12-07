terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      version = "~> 3.68.0"
      source = "hashicorp/aws"
    }
  }
}



provider "aws" {
  profile = "default"
  region = "eu-central-1"
}


