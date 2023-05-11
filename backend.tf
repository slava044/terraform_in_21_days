terraform {
  backend "s3" {
    bucket = "tfremote-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform_state_lock"
  }
}