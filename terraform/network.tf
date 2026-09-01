resource "aws_vpc" "random-cats" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.random-cats.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.random-cats.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-2a"

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1a"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.random-cats.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-2b"

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1b"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.random-cats.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}
