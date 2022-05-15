data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = ["Main VPC"]
  }
}

#data "aws_subnets" "public_subnet" {
#  filter {
#    name   = "tag:Name"
#    values = ["Public Subnet_0","Public Subnet_1" ]
#  }
#}


data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Name"
    values = ["Private Subnet_0", "Private Subnet_1"]
  }
}
