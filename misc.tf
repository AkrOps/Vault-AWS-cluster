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
  ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu.id
  seal_kms_key_arn = var.seal_kms_key_arn != null ? var.seal_kms_key_arn : aws_kms_key.vault[0].arn

  # Instance egress security group rule
  instance_egress_from_port   = var.instance_egress_from_port != null ? var.instance_egress_from_port : 0
  instance_egress_to_port     = var.instance_egress_to_port != null ? var.instance_egress_to_port : 0
  instance_egress_protocol    = var.instance_egress_protocol != null ? var.instance_egress_protocol : "-1"
  instance_egress_cidr_blocks = var.instance_egress_cidrs != null ? var.instance_egress_cidrs : ["0.0.0.0/0"]
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
