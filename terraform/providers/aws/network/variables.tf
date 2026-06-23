variable "name_prefix" {

  description = "Prefix used to name network resources."

  type = string

}

variable "vpc_cidr" {

  description = "CIDR block assigned to the VPC."

  type = string

}

variable "subnet_cidr" {

  description = "CIDR block assigned to the public subnet."

  type = string

}

variable "tags" {

  description = "Common tags applied to all resources."

  type = map(string)

}