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