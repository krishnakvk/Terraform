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
