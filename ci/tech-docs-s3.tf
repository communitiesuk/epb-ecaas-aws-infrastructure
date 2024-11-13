resource "aws_s3_bucket" "tech-docs-s3" {
  bucket        = var.tech_docs_bucket_name
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.tech-docs-s3.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}