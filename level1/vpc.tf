module "vpc" {
  source = "../modules/vpc"

  env_prefix         = var.env_prefix
  vpc_cidr           = var.vpc_cidr
  public_cidr        = var.public_cidr
  private_cidr       = var.private_cidr
  availability_zones = var.availability_zones
}
