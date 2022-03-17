provider "aws" {
  region = var.aws_region
}

resource "random_pet" "env" {
  length    = 2
  separator = "_"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "vault-cluster-${random_pet.env.id}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "vault-cluster-${random_pet.env.id}"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = "${var.aws_region}${local.AZs[count.index % 3]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "vault-cluster-${random_pet.env.id}"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "vault-cluster-${random_pet.env.id}"
  }
}

resource "aws_route_table_association" "route" {
  count          = 3
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.route.id
}
