output "public_ip" {
  value = module.platform.public_ip
}

output "vm_ip" {
  value = module.platform.public_ip
}

output "instance_id" {
  value = module.platform.instance_id
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

output "ssh_user" {
  value = module.platform.ssh_user
}

output "ssh_private_key" {
  value     = module.platform.ssh_private_key
  sensitive = true
}