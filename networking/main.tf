# vpc/main.tf

data "aws_availability_zones" "available" {

}

resource "aws_vpc" "lab_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "LAB-VPC-1"
    Env  = "TEST"
  }
}



resource "aws_subnet" "lab_public_subnet" {
  count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[count.index]

  tags = {
    Name = "LAB-PUBLIC-SN-${count.index + 1}"
    Env  = "TEST"
  }
}

resource "aws_subnet" "labs_private_subnet" {
  count                   = length(var.private_cidrs)
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = var.azs[count.index]

  tags = {
    Name = "LAB-PRIVATE-SN-${count.index + 1}"
    Env  = "TEST"
  }
}

resource "aws_db_subnet_group" "lab_db_subnetgroup" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "lab_db_subnetgroup"
  subnet_ids = aws_subnet.labs_private_subnet.*.id

  tags = {
    Name = "lab_db_subnetgroup"
    Env  = "TEST"
  }
}


resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "LAB-IGW"
    Env  = "TEST"
  }
}

resource "aws_route_table" "lab_public_route_table" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "LAB-PUBLIC-RT"
    Env  = "TEST"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.lab_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab_igw.id
}

resource "aws_route_table_association" "lab_public_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.lab_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.lab_public_route_table.id
}


resource "aws_default_route_table" "lab_private_route_table" {
  default_route_table_id = aws_vpc.lab_vpc.default_route_table_id

  tags = {
    Name = "LAB-PRIVATE-RT"
    Env  = "TEST"
  }
}

#############################
##### SECURITY GROUPS #######
#############################

resource "aws_security_group" "generalpurpose_sg" {
  name        = "generalpurpose-sg"
  description = "Security group for generic access"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "loadbalancer_sg" {
  name        = "loadbalancer-sg"
  description = "Security group of loadbalancer"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "webservers_sg" {
  name        = "webservers-sg"
  description = "Security group of webservers"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.loadbalancer_sg.id]
  }

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.loadbalancer_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}