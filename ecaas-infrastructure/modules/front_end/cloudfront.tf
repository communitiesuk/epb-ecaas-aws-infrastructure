resource "aws_cloudfront_origin_access_control" "this" {
  name                              = aws_s3_bucket.frontend_s3.bucket_domain_name
  description                       = "Front end S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "front_end_cloudfront_distribution" {
  origin {
    domain_name              = aws_s3_bucket.frontend_s3.bucket_domain_name
    origin_id                = "S3-${var.front_end_s3_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }
  origin {
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1"]
    }
    domain_name = trimsuffix(trimprefix(aws_lambda_function_url.front_end_lambda_url.function_url, "https://"), "/")
    origin_id   = "nuxt-ssr-engine"
  }
  default_root_object = "/server/index.mjs"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100" # Affects CDN distribution https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "nuxt-ssr-engine"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

  }

  ordered_cache_behavior {
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["GET", "HEAD"]
    path_pattern           = "static/*"
    target_origin_id       = "S3-${var.front_end_s3_bucket_name}"
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  # If there is a 404, return index.html with a HTTP 200 Response
  custom_error_response {
    error_caching_min_ttl = 3000
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }


  # Restricts who is able to access this content
  restrictions {
    geo_restriction {
      # type of restriction, blacklist, whitelist or none
      restriction_type = "none"
    }
  }

  # TODO link to custom domain
  # SSL certificate for the service.
  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}