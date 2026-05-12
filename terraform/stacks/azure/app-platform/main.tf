module "resource_group" {
  source = "../../../providers/azure/resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "network" {
  source = "../../../providers/azure/network"

  name_prefix         = var.name_prefix
  location            = var.location

  resource_group_name = module.resource_group.name

  tags                = var.tags
}

module "registry" {
  source = "../../../providers/azure/registry"

  acr_name            = var.acr_name
  location            = var.location

  resource_group_name = module.resource_group.name

  tags                = var.tags
}

module "identity" {
  source = "../../../providers/azure/identity"

  name_prefix         = var.name_prefix
  location            = var.location

  resource_group_name = module.resource_group.name

  acr_id              = module.registry.acr_id

  tags                = var.tags
}

module "compute" {
  source = "../../../providers/azure/compute"

  name_prefix         = var.name_prefix
  location            = var.location

  resource_group_name = module.resource_group.name

  subnet_id           = module.network.subnet_id

  vm_size             = var.vm_size
  admin_username      = var.admin_username

  ssh_public_key      = var.ssh_public_key

  registry_url        = module.registry.registry_url
  registry_username   = module.registry.registry_username
  registry_password   = module.registry.registry_password

  identity_id         = module.identity.identity_id

  tags                = var.tags
}