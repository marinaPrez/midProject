data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = ["Main VPC"]
  }
}

data "aws_subnets" "pub_subnet" {
  filter {
    name   = "tag:Name"
    values = ["Public Subnet"]
  }
}





