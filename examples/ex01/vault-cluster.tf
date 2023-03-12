module "vault_cluster" {
  source       = "../../"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.public_subnets
  ssh_key_name = var.ssh_key_name
  private_ips  = ["10.248.1.11", "10.248.2.12", "10.248.3.13"]
}
