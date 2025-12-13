terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "main_vpc"
  } 
}
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-east-1a"
    tags = {
        Name = "private_subnet_1"
    }
}  
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-east-1b"
    tags = {
        Name = "private_subnet_2"
    }
}
resource "aws_subnet" "subnet3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.3.0/24"
    availability_zone = "us-east-1a"
        tags = {
            Name = "public_subnet_1"
        }
}  
resource "aws_subnet" "subnet4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.4.0/24"  
    availability_zone = "us-east-1b"
        tags = {
            Name = "public_subnet_2"
        }   
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
    tags = {
        Name = "main_igw"
    }
}
resource "aws_eip" "nat1" {
    domain = "vpc"
    tags = {
        Name = "nat_eip"
    }
}
resource "aws_nat_gateway" "natgw1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.subnet3.id
    tags = {
        Name = "nat_gateway"
    }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
    tags = {
        Name = "public_route_table"
    }
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route{
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw1.id
  }
    tags = {
        Name = "private_route_table"
    }
}
resource "aws_route_table_association" "public_rt_assoc1" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_rt_assoc2" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "private_rt_assoc1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_rt_assoc2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private_rt.id
}