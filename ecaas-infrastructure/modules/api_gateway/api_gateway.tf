# Set up API Gateway
resource "aws_api_gateway_rest_api" "ecaas_api" {
  name        = "ECaas API"
  description = "API for ECaaS (Energy Calculation as a Service). Used for Home Energy Model calculations."

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_domain_name" "ecaas_api_domain_name" {
  certificate_arn = var.cdn_certificate_arn
  domain_name     = "api.${var.domain_name}"
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = aws_api_gateway_rest_api.ecaas_api.id
  stage_name  = aws_api_gateway_stage.DeploymentStage.stage_name
  domain_name = aws_api_gateway_domain_name.ecaas_api_domain_name.domain_name
}

resource "aws_api_gateway_integration" "gateway_integration" {
  rest_api_id = aws_api_gateway_rest_api.ecaas_api.id
  resource_id = aws_api_gateway_rest_api.ecaas_api.root_resource_id
  http_method = aws_api_gateway_method.get_api_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200,
    })
  }
}

# Set up root method
resource "aws_api_gateway_method" "get_api_method" {
  rest_api_id          = aws_api_gateway_rest_api.ecaas_api.id
  resource_id          = aws_api_gateway_rest_api.ecaas_api.root_resource_id
  http_method          = "GET"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = var.gateway_authorizer_id
  authorization_scopes = ["ecaas-api/home-energy-model"]
}

resource "aws_api_gateway_integration_response" "get_api_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.ecaas_api.id
  resource_id = aws_api_gateway_rest_api.ecaas_api.root_resource_id
  http_method = aws_api_gateway_method.get_api_method.http_method
  status_code = aws_api_gateway_method_response.api_method_response.status_code
  response_templates = {
    "application/json" = jsonencode(
      {
        "title" : "Energy Calculation as a Service",
        "version" : var.api_version,
        "links" : {
          "describedBy" : "https://docs.building-energy-calculator.communities.gov.uk/#ecaas-technical-documentation"
        }
      }
    )
  }
}

resource "aws_api_gateway_method_response" "api_method_response" {
  rest_api_id = aws_api_gateway_rest_api.ecaas_api.id
  resource_id = aws_api_gateway_rest_api.ecaas_api.root_resource_id
  http_method = aws_api_gateway_method.get_api_method.http_method
  status_code = "200"
}

# hook up lambda

resource "aws_api_gateway_resource" "ecaas_beta_api_gateway" {
  rest_api_id = aws_api_gateway_rest_api.ecaas_api.id
  parent_id   = aws_api_gateway_rest_api.ecaas_api.root_resource_id
  path_part   = "beta"
}

resource "aws_api_gateway_resource" "ecaas_fhs_compliance_api_gateway" {
  rest_api_id = aws_api_gateway_rest_api.ecaas_api.id
  parent_id   = aws_api_gateway_resource.ecaas_beta_api_gateway.id
  path_part   = "future-homes-standard-compliance"
}

resource "aws_api_gateway_method" "hem_post_method" {
  rest_api_id          = aws_api_gateway_rest_api.ecaas_api.id
  resource_id          = aws_api_gateway_resource.ecaas_fhs_compliance_api_gateway.id
  http_method          = "POST"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = var.gateway_authorizer_id
  authorization_scopes = ["ecaas-api/home-energy-model"]
}

resource "aws_api_gateway_integration" "hem_lambda" {
  rest_api_id = aws_api_gateway_rest_api.ecaas_api.id
  resource_id = aws_api_gateway_method.hem_post_method.resource_id
  http_method = aws_api_gateway_method.hem_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hem_lambda.invoke_arn
}

# canned response for 504 gateway errors

resource "aws_api_gateway_gateway_response" "gateway_timeout_response" {
  rest_api_id   = aws_api_gateway_rest_api.ecaas_api.id
  response_type = "INTEGRATION_TIMEOUT"
  status_code   = "504"
  response_templates = {
    "application/json" = jsonencode(
      {
        "errors" : [
          {
            status : "504",
            title : "Request made to calculator timed out"
          }
        ]
      }
    )
  }
}

# Set up deployment
resource "aws_api_gateway_deployment" "ecaas_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ecaas_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.ecaas_api.id,
      aws_api_gateway_rest_api.ecaas_api.description,
      aws_api_gateway_rest_api.ecaas_api.root_resource_id,
      aws_api_gateway_method.get_api_method,
      aws_api_gateway_method.hem_post_method,
      aws_api_gateway_integration.gateway_integration.id,
      aws_api_gateway_integration_response.get_api_integration_response.response_templates,
      aws_api_gateway_integration.hem_lambda.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "DeploymentStage" {
  deployment_id        = aws_api_gateway_deployment.ecaas_api_deployment.id
  rest_api_id          = aws_api_gateway_rest_api.ecaas_api.id
  stage_name           = var.stage_name
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

# Set up logging
resource "aws_api_gateway_method_settings" "DeploymentStageSettings" {
  rest_api_id = aws_api_gateway_rest_api.ecaas_api.id
  stage_name  = var.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = false // keep false otherwise Authentication access token gets written to logs
  }
}

resource "aws_cloudwatch_log_group" "ApiGatewayLogGroup" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.ecaas_api.id}/${var.stage_name}"
  retention_in_days = var.log_group_retention_in_days
}

resource "aws_api_gateway_account" "CloudwatchAccount" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
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
  name               = "api_gateway_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.AssumeRole.json
}

resource "aws_iam_role_policy_attachment" "APIGatewayPushToCloudWatchLogs" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
