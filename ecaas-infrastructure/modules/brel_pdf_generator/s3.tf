# 1. Lambda Assets Bucket (For Chromium layer)
resource "aws_s3_bucket" "lambda_assets" {
  bucket_prefix = "epb-${var.environment}-brel-lambda-assets-"
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "lambda_assets" {
  bucket = aws_s3_bucket.lambda_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "chromium_layer_zip" {
  bucket = aws_s3_bucket.lambda_assets.id
  key    = "layers/chromium-v153.0.0-arm64.zip"
  source = "${path.module}/chromium_layer.zip"
  etag   = filemd5("${path.module}/chromium-v153.0.0-layer.arm64.zip")
}

# 2. PDF Storage Bucket (holds generated PDFs for 14 days)
resource "aws_s3_bucket" "brel_pdf_storage" {
  bucket_prefix = "epb-${var.environment}-brel-pdf-storage-"
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "brel_pdf_storage" {
  bucket = aws_s3_bucket.brel_pdf_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "brel_pdf_storage_lifecycle" {
  bucket = aws_s3_bucket.brel_pdf_storage.id

  rule {
    id     = "expire-reports-after-14-days"
    status = "Enabled"

    filter {}

    expiration {
      days = 14
    }
  }
}