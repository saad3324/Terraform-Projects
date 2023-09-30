variable vpc_cidr_block {
    default = "10.0.0.0/16"
}
variable subnet_cidr_block {
    default = "10.0.10.0/24"
}
variable availability_zone {
    default = "eu-west-2a"
}
variable env_prefix {
    default = "Dev"
}
variable ec2-instance_type {
    default = "t2.micro"
}

variable jenkins_ip {
    default = "188.166.172.221/32"
}



output "ec2_public_ip" {
    value = aws_instance.myapp-ec2.public_ip
  
}
