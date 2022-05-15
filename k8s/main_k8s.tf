resource "kubernetes_service_account" "opsschool_sa" {
  depends_on = [module.eks]
  metadata {
    name      = local.k8s_service_account_name
    namespace = local.k8s_service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_admin.iam_role_arn
    }
  }
}
resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "eks-worker-management"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "eks-sg-${var.project_name}"
    env = var.tag_enviroment
  }
}
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.6.1"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids         = data.aws_subnets.private_subnets.ids

  enable_irsa = true
  
  tags = {
    Name = "eks-cluster-${var.project_name}"
    env = var.tag_enviroment
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }
  vpc_id = data.aws_vpc.vpc.id
  
  eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      instance_types         = ["t2.micro"]
      vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {
    
    eks_group_1 = {
      min_size     = 1
      max_size     = 6
      desired_size = 1
      instance_types = ["t2.micro"]
    }

    eks_group_2 = {
      min_size     = 1
      max_size     = 6
      desired_size = 1
      instance_types = ["t2.micro"]

    }
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.7.0"
  create_role                   = true
  role_name                     = "opsschool-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
