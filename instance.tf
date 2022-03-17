resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "vault-server-${random_pet.env.id}"
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
  instance_type = "t3.micro"
  count         = 3
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.ssh_key_name

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

  user_data = templatefile("${path.module}/userdata.tftpl", {
    kms_key      = aws_kms_key.vault.id,
    vault_url    = var.vault_url,
    aws_region   = var.aws_region,
    count        = count.index
    cluster_name = var.cluster_name
  })
}


resource "aws_security_group" "vault" {
  name = "vault-server-${random_pet.env.id}"
  description = "vault access"
  vpc_id = aws_vpc.vpc.id

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
