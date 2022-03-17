module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  version = "3.13"

  name = local.project_name
  cidr = "10.248.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets = ["10.248.1.0/24", "10.248.2.0/24", "10.248.3.0/24"]

  tags = {
    Name        = local.project_name
  }
}
