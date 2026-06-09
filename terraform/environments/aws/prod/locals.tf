locals {

  name_prefix = "portfolio-prod"

  aws_region = "us-east-1"

  common_tags = {
    environment = "prod"
    platform    = "aws"
    managed_by  = "terraform"
    project     = "portfolio"
  }

}