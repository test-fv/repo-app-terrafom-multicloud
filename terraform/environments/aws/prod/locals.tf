locals {

  name_prefix = "portfolio-prod"

  common_tags = {
    environment = "prod"
    platform    = "aws"
    managed_by  = "terraform"
    project     = "portfolio"
  }

}