module "vault_cluster" {
  source = "../../"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  ssh_key_name = var.ssh_key_name
}
