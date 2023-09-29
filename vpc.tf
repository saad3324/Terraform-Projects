provider "aws" {
    access_key = xxx
    secret_key = xxx
  region = "eu-west-2"
}


variable vpc_cidr_block {}
variable private_subnet_cidr_block {}
variable public_subnet_cidr_block {}




data "aws_availability_zones" "azs" {
  
}

module "myapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "my-appvpc"
  cidr = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_block
  public_subnets = var.public_subnet_cidr_block
  azs = data.aws_availability_zones.azs.names


  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true


  tags = {

    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
  }


    public_subnet_tags = {
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
        "kubernetes.io/role/elb" = 1 
    }

    private_subnet_tags = {
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
        "kubernetes.io/role/internal-elb" = 1


  }




}