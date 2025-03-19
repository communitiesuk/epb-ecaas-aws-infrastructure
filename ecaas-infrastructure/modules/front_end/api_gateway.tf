resource "aws_api_gateway_rest_api" "ecaas_frontend" {
  name        = "ECaaS frontend"
  description = "A frontend for interacting with the ECaaS service that enables building a Future Homes Standard input and submitting it to an engine."

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "frontend_app" {
  rest_api_id = aws_api_gateway_rest_api.ecaas_frontend.id
  parent_id   = aws_api_gateway_rest_api.ecaas_frontend.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "frontend_app" {
  rest_api_id   = aws_api_gateway_rest_api.ecaas_frontend.id
  resource_id   = aws_api_gateway_resource.frontend_app.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "frontend_app" {
  rest_api_id             = aws_api_gateway_rest_api.ecaas_frontend.id
  resource_id             = aws_api_gateway_method.frontend_app.resource_id
  http_method             = aws_api_gateway_method.frontend_app.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.front_end_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.ecaas_frontend.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.ecaas_frontend.id,
      aws_api_gateway_rest_api.ecaas_frontend.description,
      aws_api_gateway_rest_api.ecaas_frontend.root_resource_id,
      aws_api_gateway_method.frontend_app,
      aws_api_gateway_integration.frontend_app.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id        = aws_api_gateway_deployment.this.id
  rest_api_id          = aws_api_gateway_rest_api.ecaas_frontend.id
  stage_name           = "default"
  xray_tracing_enabled = var.xray_tracing_enabled
  depends_on           = [aws_cloudwatch_log_group.ApiGatewayLogGroup]

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.ApiGatewayLogGroup.arn
    format = jsonencode({
      "requestId" : "$context.requestId",
      "extendedRequestId" : "$context.extendedRequestId",
      "requestTime" : "$context.requestTime",
      "httpMethod" : "$context.httpMethod",
      "resourcePath" : "$context.resourcePath",
      "status" : "$context.status",
      "protocol" : "$context.protocol",
      "responseLength" : "$context.responseLength",
      "client_id" : "$context.authorizer.claims.client_id",
      "lambda_integration_request_id" : "$context.integration.requestId",
    })
  }
}

data "aws_iam_policy_document" "AssumeRole" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch" {
  name               = "frontend_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.AssumeRole.json
}

resource "aws_iam_role_policy_attachment" "push_to_cloudwatch" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_cloudwatch_log_group" "ApiGatewayLogGroup" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.ecaas_frontend.id}/default"
  retention_in_days = var.log_group_retention_in_days
}
