terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      version = "~> 3.67"
      source = "hashicorp/aws"
    }
  }
}


provider "aws" {
  region = "eu-central-1"
}
