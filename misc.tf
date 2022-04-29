terraform {
  required_version = ">= 1.1"
}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "env" {
  length    = 2
  separator = "_"
}

locals {
  AZs = ["a", "b", "c"]
  seal_kms_key_arn = var.seal_kms_key_arn != null ? var.seal_kms_key_arn : aws_kms_key.vault[0].arn
}

# Default / fallback AMI
data "aws_ami" "ubuntu" {
  most_recent = "true"
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
