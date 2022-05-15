variable "aws_region" {
 default = "us-west-2"
 description = "aws region"
}

#variable "vpc_id" {}

#variable "subnet_ids" {}

variable "tag_enviroment" {
  description = "Describe the enviroment"
  default = "kandula_marina"
}

variable "project_name" {
  type = string
  default = "kandula_marina"
}

variable "eks_cluster_name" {
  default = "mid-project-eks-cluster"

 }

variable "kubernetes_version" {
  default = 1.21
  description = "kubernetes version"
}
locals {
  k8s_service_account_namespace = "default"
  k8s_service_account_name      = "opsschool-sa"
}
