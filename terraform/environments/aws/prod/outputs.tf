############################################################
# Compute
############################################################

output "public_ip" {

  value = module.platform.public_ip

}

output "vm_ip" {

  value = module.platform.public_ip

}

output "instance_id" {

  value = module.platform.instance_id

}

############################################################
# Registry
############################################################

output "registry_url" {

  value = module.platform.registry_url

}

output "registry_server" {

  value = module.platform.registry_server

}

output "repository_name" {

  value = module.platform.repository_name

}

############################################################
# Runtime
############################################################

output "runtime_bucket_name" {

  value = module.platform.runtime_bucket_name

}

output "runtime_bucket_arn" {

  value = module.platform.runtime_bucket_arn

}