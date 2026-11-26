data "archive_file" "aws_lambda_placeholder_archive" {
  type        = "zip"
  output_path = "${path.module}/placeholder_deployment.zip"

  source {
    content  = "export const handler = async () => ({ statusCode: 200, body: 'placeholder' });"
    filename = "index.mjs"
  }
}

data "archive_file" "chromium_layer_placeholder_archive" {
  type        = "zip"
  output_path = "${path.module}/placeholder_chromium_layer.zip"

  source {
    content  = "// placeholder layer replaced by CI pipeline"
    filename = "nodejs/placeholder.js"
  }
}

resource "aws_lambda_layer_version" "chromium_layer" {
  layer_name               = "chromium_layer"
  description              = "Initial placeholder Chromium layer (managed by CI)"
  filename                 = data.archive_file.chromium_layer_placeholder_archive.output_path
  source_code_hash         = data.archive_file.chromium_layer_placeholder_archive.output_base64sha256
  compatible_runtimes      = ["nodejs22.x"]
  compatible_architectures = ["arm64"]

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_lambda_function" "brel_pdf_generator_lambda" {
  filename      = data.archive_file.aws_lambda_placeholder_archive.output_path
  function_name = "brel-pdf-generator-lambda"
  role          = aws_iam_role.brel_pdf_generator_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  architectures = ["arm64"]
  memory_size   = 2048
  timeout       = 30
  layers        = [aws_lambda_layer_version.chromium_layer.arn]
  kms_key_arn   = aws_kms_key.brel_pdf_generator.arn

  lifecycle {
    ignore_changes = [filename, source_code_hash, layers]
  }

  environment {
    variables = {
      NODE_ENV           = "production"
      PDF_STORAGE_BUCKET = aws_s3_bucket.brel_pdf_storage.id
    }
  }
}

resource "aws_lambda_function_url" "brel_pdf_generator_lambda_url" {
  function_name      = aws_lambda_function.brel_pdf_generator_lambda.function_name
  authorization_type = "AWS_IAM"
}

resource "aws_cloudwatch_log_group" "brel_pdf_generator_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.brel_pdf_generator_lambda.function_name}"
  retention_in_days = var.log_group_retention_in_days
  kms_key_id        = aws_kms_key.brel_pdf_generator.arn

  depends_on = [aws_kms_key.brel_pdf_generator]
}

resource "aws_cloudwatch_metric_alarm" "brel_pdf_generator_errors" {
  alarm_name          = "brel-pdf-generator-lambda-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when brel-pdf-generator-lambda encounters an execution error"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.brel_pdf_generator_lambda.function_name
  }

  # TODO: Left empty whilst only in integration but to connect to module.alerts SNS topic when releasing to production.
  alarm_actions = []
}

resource "aws_iam_role" "brel_pdf_generator_lambda_role" {
  name               = "brel-pdf-generator-role"
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

resource "aws_iam_role_policy_attachment" "brel_pdf_generator_lambda_logs" {
  role       = aws_iam_role.brel_pdf_generator_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "invoke_brel_pdf_generator_lambda" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.brel_pdf_generator_lambda.arn]
  }
}

resource "aws_iam_policy" "invoke_brel_pdf_generator_lambda" {
  name   = "hem-lambda-invoke-pdf"
  policy = data.aws_iam_policy_document.invoke_brel_pdf_generator_lambda.json
}

resource "aws_iam_role_policy_attachment" "hem_invoke_pdf" {
  role       = var.invoking_role_name
  policy_arn = aws_iam_policy.invoke_brel_pdf_generator_lambda.arn
}

data "aws_iam_policy_document" "brel_pdf_s3_write" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.brel_pdf_storage.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = [
      aws_kms_key.brel_pdf_generator.arn
    ]
  }
}

resource "aws_iam_policy" "brel_pdf_s3_write" {
  name   = "brel-pdf-generator-s3-write"
  policy = data.aws_iam_policy_document.brel_pdf_s3_write.json
}

resource "aws_iam_role_policy_attachment" "brel_pdf_s3_write" {
  role       = aws_iam_role.brel_pdf_generator_lambda_role.name
  policy_arn = aws_iam_policy.brel_pdf_s3_write.arn
}

data "aws_iam_policy_document" "hem_lambda_read_pdf" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.brel_pdf_storage.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      aws_kms_key.brel_pdf_generator.arn
    ]
  }
}

resource "aws_iam_policy" "hem_lambda_read_pdf" {
  name   = "hem-lambda-read-brel-pdf"
  policy = data.aws_iam_policy_document.hem_lambda_read_pdf.json
}

resource "aws_iam_role_policy_attachment" "hem_read_pdf" {
  role       = var.invoking_role_name
  policy_arn = aws_iam_policy.hem_lambda_read_pdf.arn
}