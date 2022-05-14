module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.6.1"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids         = data.aws_subnets.prv_subnet.ids

  enable_irsa = true
  
  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  #vpc_id = module.vpc.vpc_id
  #vpc_id = "vpc-077722a83f309aa16"
   vpc_id =data.aws_vpc.vpc.id

  eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      instance_types         = ["t3.medium"]
      vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {
    
    group_1 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      instance_types = ["t3.medium"]
    }

    group_2 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      instance_types = ["t3.large"]

    }
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}
