module "network" {
  source = "../../../providers/aws/network"

  name_prefix = var.name_prefix
  tags        = var.tags
}

module "registry" {
  source = "../../../providers/aws/registry"

  repository_name = var.repository_name
  tags            = var.tags
}

module "identity" {
  source = "../../../providers/aws/identity"
  name_prefix = var.name_prefix
}

module "compute" {
  source = "../../../providers/aws/compute"

  name_prefix = var.name_prefix

  instance_type = var.instance_type

  subnet_id         = module.network.subnet_id
  security_group_id = module.network.security_group_id

  instance_profile_name = module.identity.instance_profile_name

  registry_url = module.registry.registry_url

  aws_region = var.aws_region

  tags = var.tags
}