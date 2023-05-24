resource "aws_launch_configuration" "main" {
  name                 = var.env_prefix
  image_id             = data.aws_ami.amazonLinux.id
  instance_type        = "t3.micro"
  security_groups      = [aws_security_group.private.id]
  user_data            = file("userdata.sh")
  iam_instance_profile = aws_iam_instance_profile.main.name
}

resource "aws_autoscaling_group" "main" {
  name                      = var.env_prefix
  max_size                  = 3
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 20
  force_delete              = true

  target_group_arns    = [aws_lb_target_group.main.arn]
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier  = data.terraform_remote_state.level1.outputs.private_subnet_id

  tag {
    key                 = "Name"
    value               = var.env_prefix
    propagate_at_launch = true
  }
}
