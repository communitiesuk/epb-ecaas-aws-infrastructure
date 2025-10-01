data "archive_file" "aws_lambda_placeholder_archive" {
  type        = "zip"
  source_file = "bootstrap"
  output_path = "bootstrap.zip"
}

resource "aws_lambda_function" "hem_lambda" {
  filename      = data.archive_file.aws_lambda_placeholder_archive.output_path
  function_name = "hem-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  architectures = ["arm64"]
  timeout       = 60
  memory_size   = 8192

  environment {
    variables = {
      SENTRY_ENVIRONMENT = var.environment
    }
  }

  tracing_config {
    mode = var.tracing_config_mode
  }
}

resource "aws_cloudwatch_log_group" "hem_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.hem_lambda.function_name}"
  retention_in_days = var.log_group_retention_in_days
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}

data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_logging" {
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

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_permission" "api_gateway_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hem_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ecaas_api.execution_arn}/*/*"
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

resource "aws_iam_policy" "xray_tracing" {
  name        = "xray_tracing"
  path        = "/"
  description = "IAM policy for x-ray tracing from a lambda"
  policy      = data.aws_iam_policy_document.xray_tracing.json
}

resource "aws_iam_role_policy_attachment" "xray_tracing" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.xray_tracing.arn
}
