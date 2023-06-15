
module "rds" {
  source = "../modules/rds"

  env_code              = var.env_code
  source_security_group = module.asg.security_group_id
  subnet_ids            = data.terraform_remote_state.level1.outputs.private_subnet_id
  rds_password          = local.rds_password
  vpc_id                = data.terraform_remote_state.level1.outputs.vpc_id
}
