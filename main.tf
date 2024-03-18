//NETWORKING

module "networking" {
  source = "./modules/networking"

  vpc_name           = "${var.app_info.name}_vpc"
  cidr_range         = var.vpc_cidr_range
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
}

// SECURITY


module "ssh_egress_sg" {
  source = "./modules/security/ssh_egress"
  vpc_id = module.networking.vpc_id

}

module "web_egress_sg" {
  source = "./modules/security/web_egress"
  vpc_id = module.networking.vpc_id

}

module "app_ingress_internal_sg" {
  source = "./modules/security/app_ingress_internal"
  vpc_id = module.networking.vpc_id
  port = 3000
  internal_source = module.networking.default_security_group_id
}

module "app_ingress_sg" {
  source = "./modules/security/app_ingress"
  vpc_id = module.networking.vpc_id
  port = 3000
}

module "ssh_bastion_sg" {
  source = "./modules/security/ssh_bastion"
  vpc_id = module.networking.vpc_id
}

// DYNAMODB

module "dynamo" {
  for_each = toset(["lights", "heating"])
  source = "./modules/dynamo"
  table_name = each.value
  hash_key = {
    type = "N"
    name = "id"
  }
}

// INSTANCES

module "secrets_instance_profile" {
  source = "./modules/servers/secrets-ip"
}


module "ssh_bastion_key" {
  source = "./modules/servers/key_pair"
  name = "ssh-bastion"
}

module "ssh-bastion" {
  source = "./modules/servers/server"
  name = "ssh-bastion"
  type = "t2.micro"
  subnet_id = module.networking.public_subnets[0]
  security_group_ids = [module.ssh_egress_sg.sg_id]
  inbound_ssh_permissions = {key_name = "ssh-bastion", sg_id = module.ssh_bastion_sg.ssh_myip_to_bastion_sg_id}
}

module "web_servers" {
  source = "./modules/servers/server"
  for_each = var.app_info.microservices.web
  name = each.key
  type = "t2.micro"
  subnet_id = module.networking.public_subnets[1]
  security_group_ids = [module.app_ingress_sg.sg_id, module.ssh_egress_sg.sg_id, module.web_egress_sg.sg_id]
  inbound_ssh_permissions = {key_name= "ssh-bastion", sg_id = module.ssh_bastion_sg.ssh_bastion_to_app_sg_id}
  app_source = "ce-smart-home-${each.key}"
  ip_name = module.secrets_instance_profile.ip_name
}


module "internal_servers" {
  source = "./modules/servers/server"
  for_each = var.app_info.microservices.internal
  name = each.key
  type = "t2.micro"
  subnet_id = module.networking.private_subnets[0]
  security_group_ids = [module.app_ingress_internal_sg.sg_id, module.ssh_egress_sg.sg_id, module.web_egress_sg.sg_id]
  inbound_ssh_permissions = {key_name = "ssh-bastion", sg_id = module.ssh_bastion_sg.ssh_bastion_to_app_sg_id}
  app_source = "ce-smart-home-${each.key}"
  ip_name = module.secrets_instance_profile.ip_name
}