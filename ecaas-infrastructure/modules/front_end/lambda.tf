data "archive_file" "aws_lambda_placeholder_archive" {
  type        = "zip"
  source_file = "bootstrap"
  output_path = "bootstrap.zip"
}

resource "aws_lambda_function" "front_end_lambda" {
  filename      = data.archive_file.aws_lambda_placeholder_archive.output_path
  function_name = "front-end-lambda"
  role          = aws_iam_role.front_end_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  architectures = ["arm64"]
  timeout       = 30
  memory_size   = 1024

  environment {
    variables = {
      NUXT_APP_CDN_URL                = "https://${var.domain_name}/static"
      NUXT_OAUTH_COGNITO_REDIRECT_URL = "https://${var.domain_name}/auth/cognito"
      ECAAS_AUTH_API_URL              = var.ecaas_auth_url
      ECAAS_API_URL                   = var.ecaas_api_url
      COGNITO_USER_POOL_ID            = var.cognito_user_pool_id
      NUXT_SESSION_PASSWORD           = var.nuxt_session_password
      NUXT_REDIS_ENDPOINT             = aws_elasticache_serverless_cache.elasticache_with_valkey.endpoint[0].address
      NUXT_REDIS_PORT                 = aws_elasticache_serverless_cache.elasticache_with_valkey.endpoint[0].port
      NUXT_REDIS_PASSWORD             = random_password.lambda_user_password.result
      NUXT_REDIS_USERNAME             = aws_elasticache_user.lambda_valkey_user.user_name
      SENTRY_AUTH_TOKEN               = var.sentry_auth_token
      SENTRY_DSN                      = var.sentry_dsn
      SENTRY_ENVIRONMENT              = var.environment_name
      NODE_OPTIONS                    = "--import ./sentry.server.config.mjs"
    }
  }

  tracing_config {
    mode = var.tracing_config_mode
  }

  layers = [
    "arn:aws:lambda:eu-west-2:133256977650:layer:AWS-Parameters-and-Secrets-Lambda-Extension-Arm64:12",
  ]
}

resource "aws_cloudwatch_log_group" "front_end_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.front_end_lambda.function_name}"
  retention_in_days = var.log_group_retention_in_days
}

data "aws_iam_policy_document" "front_end_parameter_store_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "kms:Decrypt"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_parameter_store" {
  name        = "lambda_parameter_store"
  path        = "/"
  description = "IAM policy for accessing parameter store from a lambda"
  policy      = data.aws_iam_policy_document.front_end_parameter_store_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_parameter_store" {
  role       = aws_iam_role.front_end_lambda_role.name
  policy_arn = aws_iam_policy.lambda_parameter_store.arn
}

resource "aws_iam_role" "front_end_lambda_role" {
  name               = "front-end-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.front_end_assume_role_lambda.json
}

data "aws_iam_policy_document" "front_end_assume_role_lambda" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "front_end_lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "front_end_lambda_logging" {
  name        = "front_end_lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.front_end_lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.front_end_lambda_role.name
  policy_arn = aws_iam_policy.front_end_lambda_logging.arn
}

data "aws_iam_policy_document" "xray_tracing" {
  statement {
    effect = "Allow"

    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries"
    ]

    resources = ["*"]
  }
}

resource "aws_lambda_permission" "api_gateway_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.front_end_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ecaas_frontend.execution_arn}/*/*"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_elasticache_policy" {
  statement {
    effect = "Allow"

    actions = [
      "elasticache:Connect"
    ]

    resources = [
      "arn:aws:elasticache:${var.region}:${data.aws_caller_identity.current.account_id}:serverlesscache:elasticache-with-valkey",
      "arn:aws:elasticache:${var.region}:${data.aws_caller_identity.current.account_id}:serverlesscache:lambda-valkey-user"

    ]
  }
}

resource "aws_iam_policy" "lambda_elasticache_policy" {
  name        = "lambda-elasticache-policy"
  description = "IAM policy for lambda to access ElastiCache"
  policy      = data.aws_iam_policy_document.lambda_elasticache_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_elasticache" {
  role       = aws_iam_role.front_end_lambda_role.name
  policy_arn = aws_iam_policy.lambda_elasticache_policy.arn
}



resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.front_end_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
