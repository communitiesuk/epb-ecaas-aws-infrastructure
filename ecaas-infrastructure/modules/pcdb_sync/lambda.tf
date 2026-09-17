data "archive_file" "aws_lambda_placeholder_archive" {
  type        = "zip"
  source_file = "bootstrap"
  output_path = "bootstrap.zip"
}

data "aws_iam_policy_document" "pcdb_sync_lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "pcdb_sync_lambda_role" {
  name               = "pcdb-sync-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.pcdb_sync_lambda_assume_role.json
}

resource "aws_lambda_function" "pcdb_sync_lambda" {
  filename      = data.archive_file.aws_lambda_placeholder_archive.output_path
  function_name = "ecaas-pcdb-sync-lambda"
  role          = aws_iam_role.pcdb_sync_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  architectures = ["arm64"]
  timeout       = 60
  memory_size   = 1024

  environment {
    variables = {
      BUCKET_NAME     = var.bucket_name
      EXPORT_FILENAME = var.export_filename
    }
  }
}

data "aws_iam_policy_document" "lambda_dynamodb_pcdb_policy_document" {
  statement {
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:Scan",
      "dynamodb:PutItem"
    ]
    resources = [
      aws_dynamodb_table.products_table.arn
    ]
  }
}

resource "aws_iam_policy" "lambda_dynamodb_pcdb_policy" {
  name        = "lambda-dynamodb-pcdb-policy"
  description = "This policy will be used by the lambda to batch write and scan data from DynamoDB"
  policy      = data.aws_iam_policy_document.lambda_dynamodb_pcdb_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_pcdb_policy" {
  role       = aws_iam_role.pcdb_sync_lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_pcdb_policy.arn
}

resource "aws_cloudwatch_log_group" "pcdb_sync_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.pcdb_sync_lambda.function_name}"
  retention_in_days = var.log_group_retention_in_days
}

data "aws_iam_policy_document" "pcdb_sync_lambda_logging" {
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

resource "aws_iam_policy" "pcdb_sync_lambda_logging" {
  name        = "pcdb_sync_lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.pcdb_sync_lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.pcdb_sync_lambda_role.name
  policy_arn = aws_iam_policy.pcdb_sync_lambda_logging.arn
}
