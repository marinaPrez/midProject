terraform {
  backend "s3" {
    bucket = "terraform-bucket-opsschool"
    key    = "terraform.tfstate"
    dynamodb_table = "terraform_dynamodb_oppschool"
    region = "us-west-2"
  }
}

