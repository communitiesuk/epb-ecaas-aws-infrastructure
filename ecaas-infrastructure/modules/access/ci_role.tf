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
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunction",
        ]
        Resource = [
          var.hem_lambda_arn,
          var.front_end_lambda_arn,
          var.pcdb_sync_lambda_arn
        ]
      },
      {
        Effect = "Allow"
        Resource = [
          var.front_end_s3_arn,
          "${var.front_end_s3_arn}/*"
        ]
        Action = [
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:Get*",
          "s3:List*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_api_gateway_policy" {
  role       = aws_iam_role.ci_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}
