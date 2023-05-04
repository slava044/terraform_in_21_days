
resource "aws_vpc" "class" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "class-VPC"
  }
}

resource "aws_subnet" "public0" {
  vpc_id     = aws_vpc.class.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "publicsubnet"
  }
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.class.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "publicsubnet1"
  }
}

resource "aws_subnet" "private0" {
  vpc_id     = aws_vpc.class.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "privatesubnet"
  }
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.class.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "privatesubnet1"
  }
}

resource "aws_internet_gateway" "class" {
  vpc_id = aws_vpc.class.id

  tags = {
    Name = "classIGW"
  }
}

resource "aws_nat_gateway" "natg0" {
  allocation_id = aws_eip.nat0.id
  subnet_id     = aws_subnet.private0.id

  tags = {
    Name = "natg0"
  }
}

resource "aws_nat_gateway" "natg1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.private1.id

  tags = {
    Name = "natg1"
  }
}

resource "aws_eip" "nat0" {
  vpc = true
}

resource "aws_eip" "nat1" {
  vpc = true
}

resource "aws_route_table" "public0" {
  vpc_id = aws_vpc.class.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.class.id
  }
}

resource "aws_route_table" "private0" {
  vpc_id = aws_vpc.class.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natg0.id
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.class.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natg1.id
  }
}

resource "aws_route_table_association" "public0" {
  subnet_id      = aws_subnet.public0.id
  route_table_id = aws_route_table.public0.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public0.id
}

resource "aws_route_table_association" "private0" {
  subnet_id      = aws_subnet.private0.id
  route_table_id = aws_route_table.private0.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}
