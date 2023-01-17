module "api" {
    source = "./modules/api"

  vpc_id              = var.vpc_id
  solution_stack_name = var.solution_stack_name
  min_size            = var.min_size
  public_subnets      = var.public_subnets
  elb_public_subnets  = var.elb_public_subnets
  hosted_zone_id      = var.hosted_zone_id
  instance_type       = var.instance_type
  max_size            = var.max_size
}

module "web" {
  source = "./modules/web"

  hosted_zone_id = var.hosted_zone_id
}