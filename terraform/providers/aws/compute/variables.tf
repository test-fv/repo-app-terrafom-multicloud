variable "name_prefix" {

  description = "Prefix used for naming AWS compute resources."

  type = string

}

variable "instance_type" {

  description = "EC2 instance type."

  type = string

  validation {

    condition = length(var.instance_type) > 0

    error_message = "instance_type cannot be empty."

  }

}

variable "subnet_id" {

  description = "Subnet ID where the EC2 instance will be deployed."

  type = string

}

variable "security_group_id" {

  description = "Security Group ID associated with the EC2 instance."

  type = string

}

variable "instance_profile_name" {

  description = "IAM Instance Profile attached to the EC2 instance."

  type = string

}

variable "registry_url" {

  description = "Container registry URL."

  type = string

}

variable "runtime_bucket_name" {

  description = "Private S3 bucket that stores the deployment runtime."

  type = string

}

variable "aws_region" {

  description = "AWS region where resources are deployed."

  type = string

}

variable "tags" {

  description = "Common tags applied to AWS resources."

  type = map(string)

}