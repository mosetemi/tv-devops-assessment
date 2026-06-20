terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  # Restrict the provider to specific AWS accounts
}