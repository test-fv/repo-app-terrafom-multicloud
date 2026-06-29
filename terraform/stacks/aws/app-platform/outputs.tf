##############################################################################
# Compute
##############################################################################

output "public_ip" {

  description = "EC2 Public IP"

  value = module.compute.public_ip

}

output "instance_id" {

  description = "EC2 Instance ID"

  value = module.compute.instance_id

}

##############################################################################
# Registry
##############################################################################

output "registry_url" {

  description = "Container Registry URL"

  value = module.registry.registry_url

}

output "registry_server" {

  description = "Registry Server"

  value = module.registry.registry_server

}

output "repository_name" {

  description = "Repository Name"

  value = module.registry.repository_name

}

##############################################################################
# Runtime
##############################################################################

output "runtime_bucket_name" {

  description = "Runtime Bucket Name"

  value = module.identity.runtime_bucket_name

}

output "runtime_bucket_arn" {

  description = "Runtime Bucket ARN"

  value = module.identity.runtime_bucket_arn

}

##############################################################################
# Region
##############################################################################

output "aws_region" {

  description = "AWS Region"

  value = var.aws_region

}