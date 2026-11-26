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

resource "aws_s3_bucket_versioning" "lambda_assets" {
  bucket = aws_s3_bucket.lambda_assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_assets" {
  bucket = aws_s3_bucket.lambda_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.brel_pdf_generator.arn
    }
    bucket_key_enabled = true
  }
}

data "aws_iam_policy_document" "lambda_assets_deny_http" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      aws_s3_bucket.lambda_assets.arn,
      "${aws_s3_bucket.lambda_assets.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "lambda_assets" {
  bucket     = aws_s3_bucket.lambda_assets.id
  policy     = data.aws_iam_policy_document.lambda_assets_deny_http.json
  depends_on = [aws_s3_bucket_public_access_block.lambda_assets]
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

resource "aws_s3_bucket_versioning" "brel_pdf_storage" {
  bucket = aws_s3_bucket.brel_pdf_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "brel_pdf_storage" {
  bucket = aws_s3_bucket.brel_pdf_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.brel_pdf_generator.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "brel_pdf_storage_lifecycle" {
  bucket     = aws_s3_bucket.brel_pdf_storage.id
  depends_on = [aws_s3_bucket_versioning.brel_pdf_storage]

  rule {
    id     = "expire-reports-after-14-days"
    status = "Enabled"

    filter {}

    expiration {
      days = 14
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }

  rule {
    id     = "cleanup-expired-delete-markers"
    status = "Enabled"

    filter {}

    expiration {
      expired_object_delete_marker = true
    }
  }
}

data "aws_iam_policy_document" "brel_pdf_storage_deny_http" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      aws_s3_bucket.brel_pdf_storage.arn,
      "${aws_s3_bucket.brel_pdf_storage.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "brel_pdf_storage" {
  bucket     = aws_s3_bucket.brel_pdf_storage.id
  policy     = data.aws_iam_policy_document.brel_pdf_storage_deny_http.json
  depends_on = [aws_s3_bucket_public_access_block.brel_pdf_storage]
}