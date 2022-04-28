resource "aws_kms_key" "vault" {
  count                   = var.seal_kms_key_arn != null ? 0 : 1
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "${var.name_prefix}-${random_pet.env.id}"
  }
}

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

resource "aws_instance" "vault" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  count         = var.node_count
  subnet_id     = var.subnet_ids[count.index % 3]
  key_name      = var.ssh_key_name
  private_ip    = var.private_ips[count.index % 3]

  security_groups = [
    aws_security_group.vault.id,
  ]

  associate_public_ip_address = true
  ebs_optimized               = false
  iam_instance_profile        = aws_iam_instance_profile.vault-server.id

  tags = {
    Name = "vault-server-${random_pet.env.id}"
    Vault_cluster = var.cluster_name
  }

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    vault_version  = var.vault_version
    tls_secret_arn = var.tls_secret_arn
    region         = var.aws_region
    cluster_name   = var.cluster_name
    kms_key_id     = local.seal_kms_key_arn
  })
}


resource "aws_security_group" "vault" {
  name = "vault-server-${random_pet.env.id}"
  description = "vault access"
  vpc_id = var.vpc_id

  tags = {
    Name = "vault-server-${random_pet.env.id}"
  }

  # SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Vault Client Traffic
  ingress {
    from_port = 8200
    to_port = 8200
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Vault cluster traffic
  ingress {
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Internal Traffic
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
