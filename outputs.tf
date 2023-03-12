output "server_public_ips" {
  value = aws_instance.vault[*].public_ip
}

output "server_private_ips" {
  value = aws_instance.vault[*].private_ip
}
