terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "tfremote-state-bucket"
    key            = "level1.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_state_lock"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform_user"
}
