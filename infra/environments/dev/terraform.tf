terraform {
  backend "s3" {
    bucket  = "obligatorio-devops-tfstate"
    key     = "dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
