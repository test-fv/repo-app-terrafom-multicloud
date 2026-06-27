#############################################
# Compute
#############################################

output "public_ip" {
  description = "Public IP of the EC2 instance."

  value = module.compute.public_ip
}

output "instance_id" {
  description = "EC2 Instance ID."

  value = module.compute.instance_id
}

#############################################
# Registry
#############################################

output "registry_url" {
  description = "Full ECR repository URL."

  value = module.registry.registry_url
}

output "registry_server" {
  description = "ECR registry hostname."

  value = module.registry.registry_server
}

output "repository_name" {
  description = "ECR repository name."

  value = module.registry.repository_name
}

#############################################
# Runtime
#############################################

output "ssh_user" {
  description = "SSH username."

  value = "ubuntu"
}

output "ssh_private_key" {
  description = "SSH private key."

  value      = module.compute.ssh_private_key
  sensitive  = true
}