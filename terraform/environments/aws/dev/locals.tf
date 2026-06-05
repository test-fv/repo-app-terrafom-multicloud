locals {

  name_prefix = "portfolio-dev"

  common_tags = {
    environment = "dev"
    platform    = "aws"
    managed_by  = "terraform"
    project     = "portfolio"
  }

}