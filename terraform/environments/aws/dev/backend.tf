terraform {
  backend "s3" {
    bucket         = "terraform-state-fabian-multicloud"
    key            = "aws-dev.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}