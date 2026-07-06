module "network" {

  source = "../../modules/network"

  environment = var.environment

  vpc_cidr = var.vpc_cidr

  public_subnets = var.public_subnets

  private_subnets = var.private_subnets

  availability_zones = var.availability_zones

}

module "ecs" {

  source = "../../modules/ecs"

  environment = var.environment

  vpc_id = module.network.vpc_id

  public_subnet_ids = module.network.public_subnet_ids

  private_subnet_ids = module.network.private_subnet_ids

}

module "rds" {

  source = "../../modules/rds"

  environment = var.environment

  vpc_id = module.network.vpc_id

  private_subnet_ids = module.network.private_subnet_ids

  ecs_security_group_id = module.ecs.ecs_security_group_id

  db_instance_class = var.db_instance_class

  backup_retention_period = var.backup_retention_period

  deletion_protection = var.deletion_protection

  db_name = var.db_name

  db_username = var.db_username

  db_password = var.db_password

}