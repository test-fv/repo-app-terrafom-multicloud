locals {

  project_name = "portfolio"

  environment = "prod"

  platform = "aws"

  name_prefix = "${local.project_name}-${local.environment}"

  aws_region = "us-east-1"

  instance_type = "t3.micro"

  repository_name = "myapp"

  vpc_cidr = "10.0.0.0/16"

  subnet_cidr = "10.0.1.0/24"

  common_tags = {

    environment = local.environment

    platform = local.platform

    managed_by = "terraform"

    project = local.project_name

  }

}