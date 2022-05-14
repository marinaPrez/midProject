variable "kubernetes_version" {
  default = 1.21
  description = "kubernetes version"
}

variable "aws_region" {
 default = "us-west-2"
 #default = "us-east-2" 
 description = "aws region"
}

locals {
  k8s_service_account_namespace = "default"
  k8s_service_account_name      = "opsschool-sa"
}
