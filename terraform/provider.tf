terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # The bucket name contains the AWS account ID, so it is not committed.
  # Pass it at init time: terraform init -backend-config=backend.hcl
  # (copy backend.hcl.example to backend.hcl; that file is git-ignored)
  backend "s3" {
    key          = "terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.region
}
