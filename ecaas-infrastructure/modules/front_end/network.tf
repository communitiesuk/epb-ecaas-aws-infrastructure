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
  count             = length(local.availability_zones)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 2, count.index)
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



resource "aws_security_group" "elasticache_sg" {
  name        = "elasticache-sg"
  description = "ElastiCache security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    protocol        = "tcp"
    from_port       = 6379
    to_port         = 6379
    security_groups = [aws_security_group.lambda_sg.id]
    description     = "Allow traffic from lambda to ElastiCache Valkey"

  }
}
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Lambda security group"
  vpc_id      = aws_vpc.this.id
}

resource "aws_vpc_security_group_egress_rule" "lambda_to_elasticache" {
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  security_group_id            = aws_security_group.lambda_sg.id
  referenced_security_group_id = aws_security_group.elasticache_sg.id
  description                  = "Allow Lambda to connect to ElastiCache inside the VPC"
}

resource "aws_vpc_security_group_egress_rule" "lambda_to_api_gateway" {
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  security_group_id            = aws_security_group.lambda_sg.id
  referenced_security_group_id = aws_security_group.api-gateway_endpoint_sg.id
  description                  = "Allow Lambda to connect to API Gateway outside of the VPC"
}

resource "aws_vpc_security_group_egress_rule" "lambda_to_ssm" {
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  security_group_id            = aws_security_group.lambda_sg.id
  referenced_security_group_id = aws_security_group.ssm_endpoint_sg.id
  description                  = "Allow Lambda to connect to SSM (Parameter Store) outside of the VPC"
}

resource "aws_security_group" "ssm_endpoint_sg" {
  name        = "ssm-endpoint-sg"
  description = "SSM (Parameter store) security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.lambda_sg.id]
    description     = "Allow traffic from Lambda to SSM"

  }
}

resource "aws_security_group" "api-gateway_endpoint_sg" {
  name        = "api-gateway-endpoint-sg"
  description = "API Gateway security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.lambda_sg.id]
    description     = "Allow traffic from Lambda to API Gateway"

  }
}
