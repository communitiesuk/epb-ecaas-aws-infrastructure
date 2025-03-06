resource "aws_s3_bucket" "frontend_s3" {
  bucket        = var.front_end_s3_bucket_name
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.frontend_s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "s3_origin_from_cloudfront" {
  bucket = aws_s3_bucket.frontend_s3.id
  policy = data.aws_iam_policy_document.s3_origin_from_cloudfront.json
}

data "aws_iam_policy_document" "s3_origin_from_cloudfront" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.frontend_s3.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [aws_cloudfront_distribution.front_end_cloudfront_distribution.arn]
    }
  }
}