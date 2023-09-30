provider "aws" {
  region     = "eu-west-2"
  access_key = "xxx"
  secret_key = "xxx"
}





resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    
    tags = {
        Name: "${var.env_prefix}-vpc"
    }

  
}

module "myapp-subnet" {
    source = "./modules/subnet"
    
    subnet_cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id

  
}

module "myapp-webserver" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id
    image_name = var.image_name
    my_public_key_location = var.my_public_key_location
    ec2-instance-type = var.ec2-instance-type
    availability_zone = var.availability_zone
    env_prefix = var.env_prefix
    subnet_id = module.myapp-subnet.subnet.id

}





