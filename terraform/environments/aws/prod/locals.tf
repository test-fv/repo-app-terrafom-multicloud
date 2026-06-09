locals {

  name_prefix = "portfolio-prod"

  aws_region = "us-east-1"

  instance_type = "t3.micro"

  repository_name = "myapp"

  common_tags = {
    environment = "prod"
    platform    = "aws"
    managed_by  = "terraform"
    project     = "portfolio"
  }

}