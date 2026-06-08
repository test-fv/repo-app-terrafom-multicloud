output "public_ip" {
  value = module.compute.public_ip
}

output "registry_url" {
  value = module.registry.registry_url
}

output "registry_server" {
  value = module.registry.registry_server
}

output "repository_name" {
  value = module.registry.repository_name
}

output "registry_username" {
  value = "AWS_IAM"
}

output "registry_password" {
  value     = "USE_AWS_TOKEN"
  sensitive = true
}

output "ssh_user" {
  value = "ubuntu"
}

