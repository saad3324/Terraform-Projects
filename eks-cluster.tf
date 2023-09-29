module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name = "myapp-eks-cluster"
  cluster_version = "1.27"
  cluster_endpoint_public_access = true
  control_plane_subnet_ids = module.myapp-vpc.private_subnets
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  
  subnet_ids = module.myapp-vpc.private_subnets
  vpc_id = module.myapp-vpc.vpc_id

  tags = {

    environment ="Dev"
    application = "myapp"
  }

  self_managed_node_groups = {
    node1 = { 
        instance_type = "t2.micro"
        name = "node1"
        asg_desired_capacity = 1
    },

    node2 = {
        instance_type = "t2.small"
        name = "node2"
        asg_desired_capacity = 1 
    }

}

}




data "aws_eks_cluster" "myapp-cluster" {

    name = "myapp-eks-cluster"
  
}

data "aws_eks_cluster_auth" "myapp-cluster" {
    name = "myapp-eks-cluster"

  
}

provider "kubernetes" {

    
    host = data.aws_eks_cluster.myapp-cluster.endpoint
    token = data.aws_eks_cluster_auth.myapp-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)

     
  
}


