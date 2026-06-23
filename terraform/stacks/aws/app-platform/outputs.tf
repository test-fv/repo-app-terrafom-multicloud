output "public_ip" {

  description = "Public IP address of the application instance."

  value = module.compute.public_ip

}

output "registry_url" {

  description = "Full container registry URL."

  value = module.registry.registry_url

}

output "registry_server" {

  description = "Container registry server."

  value = module.registry.registry_server

}

output "repository_name" {

  description = "Container repository name."

  value = module.registry.repository_name

}

output "registry_username" {

  description = "Registry username used for authentication."

  value = "AWS_IAM"

}

output "registry_password" {

  description = "Placeholder indicating that AWS ECR authentication uses temporary tokens."

  value = "USE_AWS_TOKEN"

  sensitive = true

}

output "ssh_user" {

  description = "Default SSH user for the EC2 instance."

  value = "ubuntu"

}

output "ssh_private_key" {

  description = "Generated private key used for SSH access."

  value = module.compute.ssh_private_key

  sensitive = true

}