resource "aws_iam_role" "ci_role" {
  name        = "ci-server"
  description = "Used by a CI server operating from a separate account"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.ci_account_id}:root"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ci_api_gateway_policy" {
  name = "ci_api_gateway_policy"
  role = aws_iam_role.ci_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = ["arn:aws:s3:::${var.integration_terraform_state_bucket}/${var.api_tfstate}", var.integration_terraform_state_table_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_api_gateway_policy" {
  role       = aws_iam_role.ci_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}
