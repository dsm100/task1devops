terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

locals{
  public_cidr = ["10.0.0.0/24","10.0.1.0/24"]
  private_cidr = ["10.0.2.0/24","10.0.3.0/24"]
}
resource "aws_subnet" "public" {
  count = 2
  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_cidr[count.index]

  tags = {
    Name = "public${count.index}}"
  }
}


resource "aws_subnet" "private" {
  count = 2
  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_cidr[count.index]

  tags = {
    Name = "private${count.index}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_nat_gateway" "main" {
  count = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "main NAT"
  }
}

resource "aws_eip" "nat" {
  count = 2
  vpc = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  count = 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "private${count.index}"
  }
}