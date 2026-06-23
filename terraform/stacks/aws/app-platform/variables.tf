variable "name_prefix" {

  description = "Prefix used to name all AWS resources."

  type = string

}

variable "instance_type" {

  description = "EC2 instance type."

  type = string

}

variable "repository_name" {

  description = "Container registry repository name."

  type = string

}

variable "aws_region" {

  description = "AWS deployment region."

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