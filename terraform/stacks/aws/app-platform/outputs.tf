output "public_ip" {

  description = "Public IP of the application VM."

  value = module.compute.public_ip

}

output "instance_id" {

  description = "EC2 Instance ID."

  value = module.compute.instance_id

}

output "registry_url" {

  description = "Complete ECR repository URL."

  value = module.registry.registry_url

}

output "registry_server" {

  description = "ECR Registry hostname."

  value = module.registry.registry_server

}

output "repository_name" {

  description = "ECR repository name."

  value = module.registry.repository_name

}