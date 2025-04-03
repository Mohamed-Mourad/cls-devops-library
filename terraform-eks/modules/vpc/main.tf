// This file creates the VPC, subnets, gateways, and route tables for our EKS cluster.
// The naming follows the cls-{resource-name} scheme.

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "cls-vpc"
  }
}

# Create an Internet Gateway for public subnets.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "cls-igw"
  }
}

# Create public subnets in two different AZs.
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.public_azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "cls-public-subnet-${count.index + 1}"
  }
}

# Create private subnets in two different AZs.
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.private_azs[count.index]
  tags = {
    Name = "cls-private-subnet-${count.index + 1}"
  }
}

# Create a NAT Gateway in each public subnet.
resource "aws_eip" "nat" {
  count = length(aws_subnet.public)
  tags = {
    Name = "cls-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "this" {
  count         = length(aws_subnet.public)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "cls-nat-gateway-${count.index + 1}"
  }
}

# Create a route table for public subnets.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "cls-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Associate the public subnets with the public route table.
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create a route table for each private subnet, routing outbound traffic via the NAT Gateway.
resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "cls-private-rt-${count.index + 1}"
  }
}

resource "aws_route" "private_nat_access" {
  count                   = length(aws_subnet.private)
  route_table_id          = aws_route_table.private[count.index].id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.this[count.index % length(aws_nat_gateway.this)].id
}

# Associate each private subnet with its corresponding route table.
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
