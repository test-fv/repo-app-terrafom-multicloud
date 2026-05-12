locals {

  name_prefix = "portfolio-prod"

  common_tags = {
    environment = "prod"
    platform    = "azure"
    managed_by  = "terraform"
    project     = "portfolio"
  }

}