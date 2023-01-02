provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.2.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  backend "s3" {
    bucket  = "containar"
    key     = "global/s3/terraform.tfstate"
    encrypt = true
    region  = "us-east-1"
  }
}

locals {
  tags = {
    Project         = "${var.infrastructure_name}-GroundUp"
    Environment     = "Dev"
    Owner-Email     = "devops.chisom@gmail.com"
    Managed-By      = "Terraform"
    Billing-Account = "1234567890"
  }
  base_name = var.infrastructure_name
}

