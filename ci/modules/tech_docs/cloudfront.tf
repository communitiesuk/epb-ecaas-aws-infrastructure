resource "aws_cloudfront_origin_access_control" "this" {
  name                              = aws_s3_bucket.tech-docs-s3.bucket_domain_name
  description                       = "tech docs bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "tech_docs_s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.tech-docs-s3.bucket_domain_name
    origin_id                = "S3-${var.tech_docs_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }
  # By default, show index.html file
  default_root_object = "index.html"
  enabled             = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.tech_docs_bucket_name}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

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

  # SSL certificate for the service.
  viewer_certificate {
    cloudfront_default_certificate = true
  }


  ordered_cache_behavior {
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["GET", "HEAD"]
    path_pattern           = "*"
    target_origin_id       = "S3-${var.tech_docs_bucket_name}"
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }
}