terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = var.region
}

###########################
#create vpc
##########################

resource "aws_vpc" "oppschool_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "Main VPC"
  }
}

#######################################
#public subnets
#####################################

resource "aws_subnet" "public" {
  count      = 2
  vpc_id     = aws_vpc.oppschool_vpc.id
  cidr_block = var.public_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet_${count.index}"
  }
}

####################################
#private subnets
###################################

resource "aws_subnet" "private" {
  count      = 2
  vpc_id     = aws_vpc.oppschool_vpc.id
  cidr_block = var.private_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "Private Subnet_${count.index}"
  }
}

###################
#internet gateway
###################

resource "aws_internet_gateway" "ing" {
   vpc_id     = aws_vpc.oppschool_vpc.id
   tags = {
    Name = "Public Subnet"
  }
}

##########################
#Elastic IP for NAT Gateway
##########################
resource "aws_eip" "nat_eip" {
   vpc = true
   count = 2
   depends_on = [aws_internet_gateway.ing]
   tags = {
    Name = "NAT gateway EIP"
    }
}

###################################
#create NAT gateway
###################################

resource "aws_nat_gateway" "nat_gw" {
  count = 2
  allocation_id = aws_eip.nat_eip.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]
  tags = {
    Name = "gw_NAT_${count.index}"
  }
  depends_on = [aws_internet_gateway.ing]
}

#####################################
#create routing attributes
#####################################

resource "aws_route_table" "public" {
#  count = 1
  vpc_id = aws_vpc.oppschool_vpc.id
  route {
     cidr_block = "0.0.0.0/0" 
     gateway_id = aws_internet_gateway.ing.id
     }
  tags = {
    "Name" = "Public route table"
  }
}
resource "aws_route_table_association" "public" {
  count = 2
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  count = 2
  vpc_id = aws_vpc.oppschool_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.nat_gw.*.id[count.index]
     }
  tags = {
    "Name" = "private route table"
  }
}
resource "aws_route_table_association" "private" {
  count = 2
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}



##################################
# create ssh keys
#################################

resource "tls_private_key" "oppschool_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "oppschool_key" {
  key_name   = "demo"
  public_key = tls_private_key.oppschool_key.public_key_openssh
}
# Save generated key pair locally
  resource "local_file" "server_key" {
  sensitive_content  = tls_private_key.oppschool_key.private_key_pem
  filename           = "private.pem"
}

#######################################
#create instance profile
#####################################

resource "aws_iam_instance_profile" "web_profile" {
  name = "web_profile"
  role = "opsScool_role"
}


