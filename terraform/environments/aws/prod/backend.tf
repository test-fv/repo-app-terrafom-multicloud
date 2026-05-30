terraform {
  backend "s3" {
    bucket         = "terraform-state-fabian-multicloud"
    key            = "aws-prod.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}