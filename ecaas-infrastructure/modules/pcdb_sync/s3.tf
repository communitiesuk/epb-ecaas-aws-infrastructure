resource "aws_s3_bucket" "pcdb_s3" {
  bucket        = "epb-ecaas-pcdb"
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.pcdb_s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "s3_access_from_lambda" {
  bucket = aws_s3_bucket.pcdb_s3.id
  policy = data.aws_iam_policy_document.s3_access_from_lambda.json
}

data "aws_iam_policy_document" "s3_access_from_lambda" {
  statement {
    sid    = "AllowPcdbLambdaReadOnly"
    effect = "Allow"
    principals {
      identifiers = [aws_iam_role.pcdb_sync_lambda_role.arn]
      type        = "AWS"
    }
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.pcdb_s3.arn}/*"
    ]
  }
}