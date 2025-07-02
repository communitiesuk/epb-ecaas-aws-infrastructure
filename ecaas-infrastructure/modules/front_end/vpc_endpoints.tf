resource "aws_vpc_endpoint" "api_gateway_vpc_access" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${var.region}.apigateway"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.api-gateway_endpoint_sg.id]
  subnet_ids = aws_subnet.private.*.id
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_vpc_access" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.ssm_endpoint_sg.id]
  subnet_ids = aws_subnet.private.*.id
  private_dns_enabled = true
}
