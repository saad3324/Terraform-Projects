provider "aws" {
  region     = "eu-west-2"
  
}






resource "aws_vpc" "myapp-vpc" {
    cidr_block = "10.0.0.0/16"
    
    tags = {
        Name: "${var.env_prefix}-vpc"
    }

  
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = var.availability_zone
    tags = {
      Name: "${var.env_prefix}-subnet-1"
    }
 
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
      Name: "${var.env_prefix}-igw"
    }
  
}

resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id

    }

    tags = {
      Name: "${var.env_prefix}-rtb"
    }
     
}

resource "aws_route_table_association" "myapp-artb" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
  
}

resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.jenkins_ip]
        
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []

    }

    tags = {
      Name: "${var.env_prefix}-sg"
    }
}



data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
      name = "name"
      values = ["al2023-ami-2023.1.20230725.0-*-x86_64"]

    }
     
}





resource "aws_instance" "myapp-ec2" {
    ami = data.aws_ami.latest-amazon-linux-image.id

    instance_type = var.ec2-instance_type

    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.availability_zone

    key_name = "Eks-ssh-key-pair"

    associate_public_ip_address = true

    user_data = file("entry-point.sh")

    tags = {
      Name: "${var.env_prefix}-ec2"
    }



}

