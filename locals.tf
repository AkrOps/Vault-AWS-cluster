locals {
  AZs = ["a", "b", "c"]
  seal_kms_key_arn = var.seal_kms_key_arn != null ? var.seal_kms_key_arn : aws_kms_key.vault[0].arn
}
