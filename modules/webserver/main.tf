resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = var.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["92.40.205.17/32"]
        
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
      values = [var.image_name]

    }
     
}


resource "aws_key_pair" "ssh-key" {
    key_name = "ec2-key"
    public_key = "${file(var.my_public_key_location)}"
  
}


resource "aws_instance" "myapp-ec2" {
    ami = data.aws_ami.latest-amazon-linux-image.id

    instance_type = var.ec2-instance-type

    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.availability_zone

    key_name = aws_key_pair.ssh-key.key_name

    associate_public_ip_address = true

    user_data = file("entry-point.sh")

    tags = {
      Name: "${var.env_prefix}-ec2"
    }



}