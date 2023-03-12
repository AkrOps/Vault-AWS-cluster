resource "aws_instance" "vault" {
  ami           = local.ami_id
  instance_type = var.instance_type
  count         = var.node_count
  subnet_id     = var.subnet_ids[count.index % 3]
  key_name      = var.ssh_key_name
  private_ip    = var.private_ips[count.index % 3]

  vpc_security_group_ids = [
    aws_security_group.vault.id,
  ]

  associate_public_ip_address = true
  ebs_optimized               = false
  iam_instance_profile        = aws_iam_instance_profile.vault.id

  tags = merge(
    var.common_tags, {
      Name          = "${var.name_prefix}-${random_pet.env.id}",
      Vault_cluster = var.cluster_name
    }
  )

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    vault_version  = var.vault_version
    tls_secret_arn = var.tls_secret_arn
    region         = var.aws_region
    cluster_name   = var.cluster_name
    kms_key_id     = local.seal_kms_key_arn
  })

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}
