
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env_prefix}-public${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env_prefix}-private${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env_prefix}-main"
  }
}

resource "aws_nat_gateway" "natg" {
  count = length(var.public_cidr)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.env_prefix}-nat${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]

}

resource "aws_eip" "nat" {
  count = length(var.public_cidr)

  vpc = true

  tags = {
    Name = "${var.env_prefix}-nat${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table" "private" {
  count = length(var.private_cidr)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natg[count.index].id
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_cidr)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
