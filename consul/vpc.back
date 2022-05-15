
resource "aws_vpc" "consul_vpc" {
  cidr_block           = var.vpc_cidr_block
  tags = {
    "Name" = "consul_vpc"
  }
}

# SUBNETS
resource "aws_subnet" "public" {
  map_public_ip_on_launch = "true"
  cidr_block              = var.public_subnet
  vpc_id                  = aws_vpc.consul_vpc.id

}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.consul_vpc.id

  tags = {
    "Name" = "IGW_${aws_vpc.consul_vpc.id}"
  }
}

# ROUTING #
resource "aws_route_table" "route_tables" {
  vpc_id = aws_vpc.consul_vpc.id

  tags = {
    "Name" = "consul_RTB_${aws_vpc.consul_vpc.id}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route_tables.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.route_tables.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

