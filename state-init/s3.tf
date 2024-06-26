resource "aws_s3_bucket" "epbr_s3_terraform_state" {
  bucket        = "epbr-${var.environment}-terraform-state"
  force_destroy = false
}

resource "aws_s3_bucket_ownership_controls" "private_acl" {
  bucket = aws_s3_bucket.epbr_s3_terraform_state.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "private_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.private_acl]

  bucket = aws_s3_bucket.epbr_s3_terraform_state.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.epbr_s3_terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket                  = aws_s3_bucket.epbr_s3_terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
