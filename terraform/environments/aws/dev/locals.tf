locals {

  name_prefix = "portfolio-dev"

  aws_region = "us-east-1"

  common_tags = {
    environment = "dev"
    platform    = "aws"
    managed_by  = "terraform"
    project     = "portfolio"
  }

}