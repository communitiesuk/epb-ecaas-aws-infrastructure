resource "aws_cloudfront_cache_policy" "cache_policy" {
  name        = "cache-policy"
  default_ttl = 50
  max_ttl     = 100
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Authorization"]
      }
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}


resource "aws_cloudfront_distribution" "api_gateway_cloudfront_distribution" {
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100" # Affects CDN distribution https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html
  web_acl_id      = aws_wafv2_web_acl.ecaas_web_acl.arn

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
    acm_certificate_arn      = var.cdn_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods          = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods           = ["HEAD", "GET", "OPTIONS"]
    target_origin_id         = "ApiGatewayOrigin"
    cache_policy_id          = aws_cloudfront_cache_policy.cache_policy.id
    viewer_protocol_policy   = "allow-all"
  }
}

resource "aws_shield_protection" "ecaas_cloudfront" {
  name         = "ecaas_cloudfront_protection"
  resource_arn = aws_cloudfront_distribution.api_gateway_cloudfront_distribution.arn
}
