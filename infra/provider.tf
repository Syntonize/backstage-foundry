provider "aws" {
  region  = "eu-west-1"
}

terraform {
  required_version = "~> 1.9.0"

  backend "s3" {
    bucket         = "eu-west-1-syntonize-aws-baseline-terraform-state-prod"
    dynamodb_table = "terraform-lock"
    key            = "bandits.tfstate"
    region         = "eu-west-1"
  }
}
