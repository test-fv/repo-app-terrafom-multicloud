# variables.tf for compute
variable "name_prefix" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnet_id" {}
variable "vm_size" {}
variable "admin_username" {}
variable "ssh_public_key" {}

variable "registry_url" {}
variable "registry_username" {}
variable "registry_password" {}

variable "tags" {}

variable "identity_id" {}