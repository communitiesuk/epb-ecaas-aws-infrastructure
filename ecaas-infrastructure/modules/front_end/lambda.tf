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
  runtime       = "nodejs20.x"
  architectures = ["arm64"]
  timeout       = 30
  memory_size   = 1024

  environment {
    variables = {
      # should be inferred from the resource, but this currently creates circular reference
      # __may__ be resolvable after migrating to using api gateway rather than lambda function
      # NUXT_APP_CDN_URL = "https://${aws_cloudfront_distribution.front_end_cloudfront_distribution.domain_name}/static"
      NUXT_APP_CDN_URL = "https://dimijf1zo5k0x.cloudfront.net/static"
    }
  }

  tracing_config {
    mode = var.tracing_config_mode
  }
}

resource "aws_cloudwatch_log_group" "front_end_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.front_end_lambda.function_name}"
  retention_in_days = var.log_group_retention_in_days
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