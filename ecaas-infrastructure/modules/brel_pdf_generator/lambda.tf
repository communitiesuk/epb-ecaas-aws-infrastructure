data "archive_file" "aws_lambda_placeholder_archive" {
  type        = "zip"
  output_path = "${path.module}/placeholder.zip"

  source {
    content  = "export const handler = async () => ({ statusCode: 200, body: 'placeholder' });"
    filename = "index.mjs"
  }
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

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }

  environment {
    variables = {
      NODE_ENV = "production"
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
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.invoke_brel_pdf_generator_lambda.arn
}