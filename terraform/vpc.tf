data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_vpc" "skillboard" {
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  cidr_block = local.vpc_cidr

  tags = {
    Name = "Skillboard"
  }

}

resource "aws_eip" "ngw" {
  vpc = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.skillboard.id
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.dmz.id
  depends_on = [
    aws_internet_gateway.igw
  ]
}

# Rout Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.skillboard.id
  tags   = local.dmz_subnet_tags
}

resource "aws_route" "pub_default_gateway" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.skillboard.id
}

resource "aws_route" "private_default_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_subnet" "dmz" {
  vpc_id                  = aws_vpc.skillboard.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 4, 0)
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = local.dmz_subnet_tags
}

resource "aws_route_table_association" "pub_dmz" {
  subnet_id      = aws_subnet.dmz.id
  route_table_id = aws_route_table.public.id
}

# DB's/Redis/Cache
resource "aws_subnet" "db" {
  vpc_id                  = aws_vpc.skillboard.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 4, 2)
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = local.db_subnet_tags
}

resource "aws_route_table_association" "priv_db" {
  subnet_id      = aws_subnet.db.id
  route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "app" {
  vpc_id                  = aws_vpc.skillboard.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 4, 4)
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = local.app_subnet_tags
}

resource "aws_route_table_association" "priv_app" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.private.id
}
