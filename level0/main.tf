resource "aws_s3_bucket" "terraform_remote_state" {
  bucket = "tfremote-state-bucket"
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform_state_lock"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}