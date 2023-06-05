resource "aws_security_group" "private" {
  name        = "${var.env_prefix}-private"
  description = "Allow ssh inbound from vpc"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP form load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.lb_security_group_id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env_prefix}-private"
  }

}

resource "aws_launch_configuration" "main" {
  name                 = var.env_prefix
  image_id             = var.ami_id
  instance_type        = "t3.micro"
  security_groups      = [aws_security_group.private.id]
  user_data            = file("${path.module}/userdata.sh")
  iam_instance_profile = aws_iam_instance_profile.main.name
}

resource "aws_autoscaling_group" "main" {
  name                      = var.env_prefix
  max_size                  = 3
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 20
  force_delete              = true

  target_group_arns    = [var.target_group_arn]
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier  = var.private_subnet_id

  tag {
    key                 = "Name"
    value               = var.env_prefix
    propagate_at_launch = true
  }
}
