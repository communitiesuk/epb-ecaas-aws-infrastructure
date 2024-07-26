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
          "dynamodb:DeleteItem",
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:GetFunction",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:UpdateAssumeRolePolicy",
          "iam:PassRole",
        ]
        Resource = [
          "arn:aws:s3:::${var.integration_terraform_state_bucket}/*",
          var.integration_terraform_state_table_arn,
          var.integration_hem_lambda_arn,
          var.integration_aws_lambda_role,
          var.integration_cargo_lambda_role,
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:ListRolePolicies",
          "iam:GetPolicyVersion",
          "iam:ListAttachedRolePolicies",
          "iam:PassRole",
          "lambda:ListVersionsByFunction",
          "lambda:GetFunctionCodeSigningConfig",
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_api_gateway_policy" {
  role       = aws_iam_role.ci_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}
