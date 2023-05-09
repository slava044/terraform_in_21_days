data "aws_ami" "amazonLinux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazonLinux.id
  instance_type               = "t3.micro"
  key_name                    = "class"
  vpc_security_group_ids      = [aws_security_group.public.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public[0].id

  tags = {
    Name = "${var.env_prefix}-public"
  }
}

resource "aws_security_group" "public" {
  name        = "${var.env_prefix}-public"
  description = "Allow inbound traffic from my ip"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh from my ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["108.216.6.65/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env_prefix}-public"
  }
}

resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazonLinux.id
  instance_type          = "t3.micro"
  key_name               = "class"
  vpc_security_group_ids = [aws_security_group.public.id]
  subnet_id              = aws_subnet.private[0].id

  tags = {
    Name = "${var.env_prefix}-private"
  }
}

resource "aws_security_group" "private" {
  name        = "${var.env_prefix}-private"
  description = "Allow ssh inbound from vpc"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh from Vpc cidr range"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env_prefix}-private"
  }
}
