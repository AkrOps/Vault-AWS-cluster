variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "vault_url" {
  type    = string
  default = "https://releases.hashicorp.com/vault/1.9.3/vault_1.9.3_linux_amd64.zip"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC id where the Vault cluster should be provisioned."
}

variable "subnet_ids" {
  type        = list
  description = "A list of 3 subnet IDs in a VPC. Vault cluster nodes will be spread evenly among them."
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key pair name in AWS in order to provide initial ssh access to the cluster nodes."
}

variable "cluster_name" {
  type        = string
  description = "Cluster name. Added as the Vault_cluster tag value for every node to auto-join."
  default     = "raft-1"
}

variable "node_count" {
  type = number
  description = "The number of server nodes in the Vault cluster. Default and recommended is 3."
  default = 3
}
