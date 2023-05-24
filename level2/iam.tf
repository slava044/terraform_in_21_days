
resource "aws_iam_role" "main" {
  name                = var.env_prefix
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = var.env_prefix
  }
}

resource "aws_iam_instance_profile" "main" {
  name = var.env_prefix
  role = aws_iam_role.main.name
}
