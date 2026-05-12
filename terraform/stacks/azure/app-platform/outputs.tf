output "public_ip" {
  value = module.compute.public_ip
}

output "registry_url" {
  value = module.registry.registry_url
}

output "registry_username" {
  value = module.registry.registry_username
}

output "registry_password" {
  value     = module.registry.registry_password
  sensitive = true
}

output "ssh_user" {
  value = "azureuser"
}