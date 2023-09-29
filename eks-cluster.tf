module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name = "myapp-eks-cluster"
  cluster_version = "1.27"
  
  subnet_ids = module.myapp-vpc.private_subnets
  vpc_id = module.myapp-vpc.vpc_id

  tags = {

    environment ="Dev"
    application = "myapp"
  }

  self_managed_node_group_defaults = [
    {
        instance_type = "t2.micro"
        name = "worker-group-1"
        asg_desired_capisty = 1
    },

    {
        instance_type = "t2.small"
        name = "worker-group-2"
        asg_desired_capisty = 1 
    }
  ]

}




data "aws_eks_cluster" "myapp-cluster" {

    name = module.eks.cluster_id
  
}

data "aws_eks_cluster_auth" "myapp-cluster" {
    name = module.eks.cluster_id

  
}

provider "kubernetes" {

    
    host = data.aws_eks_cluster.myapp-cluster.endpoint
    token = data.aws_eks_cluster_auth.myapp-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)

     
  
}


