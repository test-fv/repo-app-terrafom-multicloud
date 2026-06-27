output "public_ip" {
  description = "Public IP of the virtual machine."

  value = module.compute.public_ip
}

output "instance_id" {
  description = "AWS EC2 Instance ID."

  value = module.compute.instance_id
}

output "registry_url" {
  description = "Container registry URL."

  value = module.registry.registry_url
}

output "ssh_user" {
  description = "SSH username."

  value = "ubuntu"
}

output "ssh_private_key" {
  description = "SSH private key."

  value      = module.compute.ssh_private_key
  sensitive  = true
}