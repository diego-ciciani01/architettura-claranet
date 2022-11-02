provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# terraform {
#   //backend 
#   backend "s3" {
#     bucket = "backend-statefale"
#     key    = "network/terraform.tfstate"
#     region = "eu-west-1"
#   }
# }
