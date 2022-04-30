resource "aws_kms_key" "vault" {
  count                   = var.seal_kms_key_arn != null ? 0 : 1
  description             = "Vault auto-unseal key"
  deletion_window_in_days = 10

  tags = merge(
    var.common_tags, {
      Name = "${var.name_prefix}-${random_pet.env.id}"
    }
  )
}
