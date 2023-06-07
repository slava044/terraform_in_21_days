data "aws_ami" "amazonLinux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "asg" {
  source = "../modules/asg"

  env_prefix           = "prod"
  ami_id               = data.aws_ami.amazonLinux.id
  vpc_id               = data.terraform_remote_state.level1.outputs.vpc_id
  private_subnet_id    = data.terraform_remote_state.level1.outputs.private_subnet_id
  target_group_arn     = module.lb.target_group_arn
  lb_security_group_id = module.lb.lb_security_group_id

}
