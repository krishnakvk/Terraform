provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source        = "./vpc"
  vpc_cidr      = "10.0.0.0/16"
  private_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_cidrs  = ["10.0.3.0/24", "10.0.4.0/24"]

}
module "ec2" {
  source         = "./ec2"
  instance_type  = "t2.micro"
  my_public_key  = "/tmp/id_rsa.pub"
  security_group = module.vpc.security_group
  subnets        = module.vpc.public-subnet
}

module "alb" {
  source  = "./alb"
  vpc_id  = module.vpc.vpc_id
  subnet1 = module.vpc.subnet1
  subnet2 = module.vpc.subnet2
}

module "auto_scaling" {
  source           = "./auto_scaling"
  vpc_id           = module.vpc.vpc_id
  subnet1          = module.vpc.subnet1
  subnet2          = module.vpc.subnet2
  target_group_arn = module.alb.alb_target_group_arn
}
