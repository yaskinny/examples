module "network" {
  source = "./modules/network"
}

module "app" {
  source = "./modules/app"
  ssh_privkey_path = var.ssh_privkey_path
  ssh_pubkey_path = var.ssh_pubkey_path
  local_pub_ip = var.local_pub_ip
  pub_subnet_id = module.network.pub_subnet_id
  prv_subnet_id = module.network.prv_subnet_id
  vpc_id = module.network.vpc_id
}

