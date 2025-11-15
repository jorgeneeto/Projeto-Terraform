data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


# NETWORK MODULE
module "network" {
  source = "./modules/network"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  aws_region           = var.aws_region
  tags                 = var.tags
}


# FRONTEND STATIC (S3)
module "frontend" {
  source      = "./modules/s3-frontend"
  environment = var.environment

  bucket_name = "${var.environment}-frontend-${data.aws_caller_identity.current.account_id}"
  tags        = var.tags
}


# BACKEND ECS FARGATE
module "backend" {
  source = "./modules/ecs-backend"

  aws_region      = var.aws_region
  environment     = var.environment
  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnet_ids

  container_image = var.backend_image
  container_port  = var.backend_port
  ecs_cpu         = var.ecs_cpu
  ecs_memory      = var.ecs_memory

  tags = var.tags
}


# DAILY JOB (Lambda + EventBridge)
module "daily_job" {
  source = "./modules/lambda-daily"

  environment         = var.environment
  schedule_expression = var.daily_job_cron

  bucket_name = "${var.environment}-dailyjob-${data.aws_caller_identity.current.account_id}"
  tags        = var.tags
}