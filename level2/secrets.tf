data "aws_secretsmanager_secret_version" "main" {
  secret_id = data.aws_secretsmanager_secret.rds_password.id
}

data "aws_secretsmanager_secret" "rds_password" {
  name = "main/rds/password"
}

locals {
  rds_password = jsondecode(data.aws_secretsmanager_secret_version.main.secret_string)["password"]
}
