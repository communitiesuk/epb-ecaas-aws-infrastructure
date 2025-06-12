resource "aws_elasticache_serverless_cache" "elasticache_for_valkey" {
  engine = "valkey"
  name   = "elasticache-for-valkey"
  cache_usage_limits {
    data_storage {
      maximum = 10
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
  daily_snapshot_time      = "09:00"
  description              = "Elasticache to manage Valkey cache"
  kms_key_id               = aws_kms_key.this.arn
  major_engine_version     = "7"
  snapshot_retention_limit = 1
  security_group_ids       = [aws_security_group.elasticache_sg.id]
  subnet_ids               = aws_subnet.private[*].id
  user_group_id            = aws_elasticache_user_group.lambda_valkey_group.id
}



resource "aws_security_group" "elasticache_sg" {
  name        = "elasticache-sg"
  description = "ElastiCache security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    protocol        = "tcp"
    from_port       = 6379
    to_port         = 6379
    security_groups = [aws_security_group.lambda_sg.id]
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Lambda security group"
  vpc_id      = aws_vpc.this.id

}




//KMS key to encrypt data at rest in elasticache 


resource "aws_kms_key" "this" {
  description             = "Symmetric encryption KMS key for elasticache"
  multi_region            = false
  enable_key_rotation     = true
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-for-elasticache-encryption"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow ElastiCache use of the key"
        Effect = "Allow"
        Principal = {
          Service = "elasticache.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
      }
    ]
    }
  )
}

resource "aws_kms_alias" "this" {
  name          = "alias/elasticache-encryption-key"
  target_key_id = aws_kms_key.this.key_id
}


//user and user group to authenticate lambda with valkey
resource "aws_elasticache_user" "lambda_valkey_user" {
  user_id       = "lambda-valkey-user"
  user_name     = "lambda-valkey-user"
  access_string = "on ~* +@all"
  engine        = "valkey"

  authentication_mode {
    type = "iam"
  }
}
resource "aws_elasticache_user_group" "lambda_valkey_group" {
  engine        = "valkey"
  user_group_id = "lambda-valkey-group"
  user_ids      = [aws_elasticache_user.lambda_valkey_user.user_id]
}
