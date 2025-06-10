locals {
  availability_zones = ["a", "b", "c"]
}
//check that these should be hard coded like epb

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "private" {
  count  = length(local.availability_zones)
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr, 2, count.index)
  availability_zone = "${var.region}${local.availability_zones[count.index]}"

  tags = {
    Name = "private-subnet-${local.availability_zones[count.index]}"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}
