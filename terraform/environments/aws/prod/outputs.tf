output "public_ip" {
  value = module.platform.public_ip
}

output "vm_ip" {
  value = module.platform.public_ip
}

output "registry_url" {
  value = module.platform.registry_url
}

output "registry_server" {
  value = module.platform.registry_server
}

output "repository_name" {
  value = module.platform.repository_name
}

output "registry_username" {
  value = module.platform.registry_username
}

output "registry_password" {
  value     = module.platform.registry_password
  sensitive = true
}