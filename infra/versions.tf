terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  # Backend S3 para armazenar o estado do Terraform
  backend "s3" {
    bucket = "tech-challenge-fase04-terraform-state"
    key    = "cognito/terraform.tfstate"
    region = "us-east-1"
  }
}
