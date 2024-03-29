variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "name_prefix" {
  type        = string
  description = "Prefix for tagging and naming AWS resources"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC id where the Vault cluster should be provisioned."
}

variable "subnet_ids" {
  type        = list(any)
  description = "A list of 3 subnet IDs in a VPC. Vault cluster nodes will be spread evenly among them."
}

variable "instance_type" {
  type        = string
  default     = "t3.micro" # Something like a m5.xlarge is recommended, cutting costs by default
  description = "EC2 instance type"
}

variable "ssh_key_name" {
  type        = string
  default     = null
  description = "(Optional) key pair to use for SSH access to instance"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name. Added as the Vault_cluster tag value for every node to auto-join."
  default     = "raft-1"
}

variable "node_count" {
  type        = number
  description = "The number of server nodes in the Vault cluster. Default and recommended is 3."
  default     = 3
}

variable "private_ips" {
  type        = list(any)
  description = <<EOF
    The private IP addresses to be assigned to the nodes.
    There must be a single IP for each node, i.e., private_ips length must match node_count.
    Keep in mind that nodes will be distributed evenly across a, b and c subnets.
    The IP assigned to each instance must be within that subnet's CIDR block.
    Also remember that the TLS certificate used for that node must have a matching IP SAN.
  EOF

  validation {
    condition     = can([for ip in var.private_ips : regex("^(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]\\d|\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]\\d|\\d)){3}$", ip)])
    error_message = "Err: All IPs must be valid."
  }
}

variable "tls_secret_arn" {
  type        = string
  description = "Secrets manager ARN where TLS cert info is stored"
}

variable "seal_kms_key_arn" {
  type        = string
  description = "(Optional but recommended) User-provided Vault auto-unseal KMS key ARN. A new one will be generated if none is provided."
  default     = null
}

variable "tls_secret_kms_key_arn" {
  type        = string
  description = "(Optional but recommended, defaults to seal_kms_key_arn) ARN of the KMS key used for encrypting the TLS-data secret under Secrets Manager."
  default     = null
}

variable "ami_id" {
  type        = string
  description = "(Optional) User-provided AMI ID to use with Vault instances. If you provide this value, please ensure it will work with the default userdata script (assumes latest version of Ubuntu LTS). Otherwise, please provide your own userdata script using the userdata_path variable."
  default     = null
}

variable "vault_version" {
  type        = string
  default     = "1.10.2-1"
  description = "Vault version"
}

variable "alb_sg_id" {
  type        = string
  default     = null
  description = "(Optional) Security Group ID of the cluster ALB"
}

variable "instance_egress_from_port" {
  type    = number
  default = 0
}

variable "instance_egress_to_port" {
  type    = number
  default = 0
}

variable "instance_egress_protocol" {
  type    = string
  default = "-1"
}

variable "instance_egress_cidr_blocks" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}

variable "ingress_ssh_cidrs" {
  type        = list(string)
  description = "(Optional) List of CIDR blocks to permit for SSH to Vault nodes"
  default     = null
}
