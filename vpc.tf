locals {
  public_cidr        = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_cidr       = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

resource "aws_vpc" "class" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "classVpc"
  }
}

resource "aws_subnet" "public" {
  count = length(local.public_cidr)

  vpc_id            = aws_vpc.class.id
  cidr_block        = local.public_cidr[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "public${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = length(local.private_cidr)

  vpc_id            = aws_vpc.class.id
  cidr_block        = local.private_cidr[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "private${count.index + 1}"
  }
}

resource "aws_internet_gateway" "class" {
  vpc_id = aws_vpc.class.id

  tags = {
    Name = "classgw"
  }
}

resource "aws_nat_gateway" "natg" {
  count = length(local.public_cidr)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "natg${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.class]

}

resource "aws_eip" "nat" {
  count = length(local.public_cidr)

  vpc = true

  tags = {
    Name = "nat${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.class.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.class.id
  }
}

resource "aws_route_table" "private" {
  count = length(local.private_cidr)

  vpc_id = aws_vpc.class.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natg[count.index].id
  }
}

resource "aws_route_table_association" "public" {
  count = length(local.public_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(local.private_cidr)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
