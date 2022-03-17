variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_zone" {
  type    = string
  default = "eu-central-1a"
}

variable "vault_url" {
  type    = string
  default = "https://releases.hashicorp.com/vault/1.9.3/vault_1.9.3_linux_amd64.zip"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
  default     = "10.248.0.0/16"
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key pair name in AWS"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name. Added as the Vault_cluster tag value for every node to auto-join."
  default     = "raft-1"
}
