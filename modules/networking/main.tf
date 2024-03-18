resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_range
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}


// Internet Gateway 

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "${var.vpc_name}-igw"
    ManagedBy = "Terraform"
  }
}


//  Subnet definitions

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name      = format("${var.vpc_name}-public-%s", element(var.availability_zones, count.index))
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name      = format("${var.vpc_name}-private-%s", element(var.availability_zones, count.index))
    ManagedBy = "Terraform"
  }
}


## Public Routes


resource "aws_route_table" "public" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "${var.vpc_name}-public"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}



## NAT Gateway

resource "aws_eip" "natgw-eip" {
  domain = "vpc"
  tags = { Name = "${var.vpc_name}-natgw-eip"}
}


resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw-eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.vpc_name}-natgw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

## Private Routes


resource "aws_route_table" "private-ia" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "${var.vpc_name}-private-ia"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table_association" "private-ia-assoc" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private-ia.id
}

resource "aws_route" "nat_gateway" {

  route_table_id         = aws_route_table.private-ia.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = aws_nat_gateway.natgw.id
}



