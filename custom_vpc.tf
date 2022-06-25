provider "aws" {
    region = "us-east-1"  
}
# Create VPC
resource "aws_vpc" "my-manual-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "myVpc1"
    }
}
# Create Public Subnet
resource "aws_subnet" "public-subnet" {
  vpc_id                = aws_vpc.my-manual-vpc.id
  availability_zone     = "us-east-1a"
  cidr_block            = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-public-subnet-1"
  }
}
# Create Private Subnet
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.my-manual-vpc.id
  availability_zone     = "us-east-1b"
  cidr_block = "10.0.101.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "my-private-subnet-1"
  }
}
# Create Internet Gateway and Associate it to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-manual-vpc.id
  tags = {
    Name = "my-igw"
  }
}
# Create EIP For NAT Gateway 
resource "aws_eip" "eip-nat" {
  vpc      = true
}
# Create Internet Gateway and Associate it to VPC
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip-nat.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "my-nat-gateway" 
  }
}
#Create Public Route Table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.my-manual-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "my-public-route-table"
  }
}
#Associate Public Subnet 1 in Route Table
resource "aws_route_table_association" "public-rt-ass" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

#Create Private Route Table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.my-manual-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "my-private-route-table"
  }
}
#Associate Private Subnet 1 in Route Table
resource "aws_route_table_association" "privatec-rt-ass" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

