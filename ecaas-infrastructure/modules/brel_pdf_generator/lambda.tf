data "archive_file" "aws_lambda_placeholder_archive" {
  type        = "zip"
  output_path = "${path.module}/placeholder_deployment.zip"

  source {
    content  = "export const handler = async () => ({ statusCode: 200, body: 'placeholder' });"
    filename = "index.mjs"
  }
}

resource "aws_lambda_layer_version" "chromium_layer" {
  layer_name          = "chromium_layer"
  description         = "Chromium v153.0.0 layer"
  s3_bucket           = aws_s3_bucket.lambda_assets.id
  s3_key              = aws_s3_object.chromium_layer_zip.key
  compatible_runtimes = ["nodejs22.x"]

  compatible_architectures = ["arm64"]
}

resource "aws_lambda_function" "brel_pdf_generator_lambda" {
  filename      = data.archive_file.aws_lambda_placeholder_archive.output_path
  function_name = "brel-pdf-generator"
  role          = aws_iam_role.brel_pdf_generator_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  architectures = ["arm64"]
  memory_size   = 2048
  timeout       = 30
  layers        = [aws_lambda_layer_version.chromium_layer.arn]

  lifecycle {
  ignore_changes = [filename, source_code_hash]
}

  environment {
  variables = {
    NODE_ENV           = "production"
    PDF_STORAGE_BUCKET = aws_s3_bucket.brel_pdf_storage.id
  }
}
}

resource "aws_cloudwatch_log_group" "brel_pdf_generator_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.brel_pdf_generator_lambda.function_name}"
  retention_in_days = var.log_group_retention_in_days
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
}

resource "aws_iam_policy" "brel_pdf_s3_write" {
  name   = "brel-pdf-generator-s3-write"
  policy = data.aws_iam_policy_document.brel_pdf_s3_write.json
}

resource "aws_iam_role_policy_attachment" "brel_pdf_s3_write" {
  role       = aws_iam_role.brel_pdf_generator_lambda_role.name
  policy_arn = aws_iam_policy.brel_pdf_s3_write.arn
}