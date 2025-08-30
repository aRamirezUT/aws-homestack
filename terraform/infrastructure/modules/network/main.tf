# Create a VPC
resource "aws_vpc" "aws-homestack-vpc1" {
  cidr_block       = "10.20.0.0/16"
  instance_tenancy = "default"

  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true  

  tags = {
    Name = "aws-homestack-vpc1"
  }
}

# Create public subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.aws-homestack-vpc1.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.aws-homestack-vpc1.ipv6_cidr_block, 8, count.index)


  tags = {
    Name = var.subnet_names[var.azs[count.index]]["public"]
  }
}

# Create private subnets
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.aws-homestack-vpc1.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[floor(count.index / 3)]

  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = true
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.aws-homestack-vpc1.ipv6_cidr_block, 8, count.index + length(var.public_subnet_cidrs))

  tags = {
    Name = var.subnet_names[var.azs[floor(count.index / 3)]].private[count.index % 3]
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.aws-homestack-vpc1.id

  tags = {
    Name = "aws-homestack-vpc1-igw"
  }
}

# Create an Egress-only Gateway
resource "aws_egress_only_internet_gateway" "egress-only-igw" {
  vpc_id = aws_vpc.aws-homestack-vpc1.id

  tags = {
    Name = "aws-homestack-vpc1-egress-only-igw"
  }
}

# Create a Route Table for public subnets and associate it with the Internet Gateway
resource "aws_route_table" "second_rt" {
  vpc_id = aws_vpc.aws-homestack-vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block                  = "::/0"
    egress_only_gateway_id           = aws_egress_only_internet_gateway.egress-only-igw.id
  }

  tags = {
    Name = "aws-homestack-vpc1-second-rt"
  }
}

# Associate public subnets with the route table
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.second_rt.id
}