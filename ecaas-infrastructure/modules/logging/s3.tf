resource "aws_s3_bucket" "logs" {
  bucket = "epb-${var.environment}-cloudtrail-s3-bucket"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "bucket_owner" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket                                 = aws_s3_bucket.logs.id
  transition_default_minimum_object_size = "varies_by_storage_class"
  rule {
    id     = "all_logs"
    status = "Enabled"
    filter {
      and {
        prefix                   = "/"
        object_size_greater_than = "0"
      }
    }
    expiration {
      days = 14
    }

  }
}
