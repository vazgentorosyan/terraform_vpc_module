terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.59.0"
    }
  }
  backend "s3" {
    bucket       = "terraform-tfstate-312209831674-eu-north-1-an"
    key          = "TERRAFORM-FOLDER/vpc-state.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
    encrypt      = true
  }
}
provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
