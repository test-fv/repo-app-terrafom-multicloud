module "platform" {
  source = "../../../stacks/azure/app-platform"

  name_prefix = local.name_prefix

  location            = var.location
  resource_group_name = var.resource_group_name

  acr_name = var.acr_name

  vm_size        = var.vm_size
  admin_username = var.admin_username

  ssh_public_key = var.ssh_public_key

  tags = local.common_tags
}