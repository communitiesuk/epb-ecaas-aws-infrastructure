resource "aws_cloudfront_distribution" "api_gateway_cloudfront_distribution" {
  enabled    = true
  web_acl_id = aws_wafv2_web_acl.ecaas_web_acl.arn

  origin {
    domain_name = "${aws_api_gateway_rest_api.ECaaSAPI.id}.execute-api.${var.region}.amazonaws.com"
    origin_id   = "ApiGatewayOrigin"
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["HEAD", "GET", "OPTIONS"]
    target_origin_id = "ApiGatewayOrigin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
  }
}

resource "aws_shield_protection" "ecaas_cloudfront" {
  name         = "ecaas_cloudfront_protection"
  resource_arn = aws_cloudfront_distribution.api_gateway_cloudfront_distribution.arn
}
