data "aws_caller_identity" "brel_current" {}
data "aws_region" "brel_current" {}

resource "aws_kms_key" "brel_pdf_generator" {
  description             = "Symmetric encryption KMS key for brel_pdf_generator S3, Lambda, and CloudWatch Logs"
  multi_region            = false
  enable_key_rotation     = true
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-for-brel-pdf-generator"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.brel_current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.brel_current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.brel_current.name}:${data.aws_caller_identity.brel_current.account_id}:log-group:*"
          }
        }
      },
      {
        Sid    = "Allow CI Account KMS Access"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.ci_account_id}:root"
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "brel_pdf_generator" {
  name          = "alias/brel-pdf-generator-key"
  target_key_id = aws_kms_key.brel_pdf_generator.key_id
}