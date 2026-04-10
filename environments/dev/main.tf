module "vpc" {
  source = "../../modules/vpc"

  project     = "terraform-prod"
  environment = "dev"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]

  enable_nat_gateway = true
}
module "security_group" {
  source = "../../modules/security-group"

  project     = "terraform-prod"
  environment = "dev"

  vpc_id = module.vpc.vpc_id

  # ⚠️ Replace with your IP for better security
  allowed_ssh_cidr = "0.0.0.0/0"
}
module "alb" {
  source = "../../modules/alb"

  project     = "terraform-prod"
  environment = "dev"

  vpc_id = module.vpc.vpc_id

  public_subnet_ids = module.vpc.public_subnet_ids

  alb_sg_id = module.security_group.alb_sg_id
}
module "asg" {
  source = "../../modules/asg"

  project     = "terraform-prod"
  environment = "dev"

  private_subnet_ids = module.vpc.private_subnet_ids

  ec2_sg_id = module.security_group.ec2_sg_id

  target_group_arn = module.alb.target_group_arn

  instance_type   = "t2.micro"
  desired_capacity = 2
  min_size         = 1
  max_size         = 3
}
module "ecr" {
  source = "../../modules/ecr"

  project     = "terraform-prod"
  environment = "dev"
 
}