# Set up API Gateway
resource "aws_api_gateway_rest_api" "ECaaSAPI" {
  name        = "ECaas API"
  description = "API for ECaaS (Energy Calculation as a Service). Used for Home Energy Model calculations."

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_domain_name" "ECaaSAPIDomainName" {
  certificate_arn = var.cdn_certificate_arn
  domain_name     = "api.${var.domain_name}"
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = aws_api_gateway_rest_api.ECaaSAPI.id
  stage_name  = aws_api_gateway_stage.DeploymentStage.stage_name
  domain_name = aws_api_gateway_domain_name.ECaaSAPIDomainName.domain_name
}

resource "aws_api_gateway_integration" "GatewayIntegration" {
  rest_api_id = aws_api_gateway_rest_api.ECaaSAPI.id
  resource_id = aws_api_gateway_rest_api.ECaaSAPI.root_resource_id
  http_method = aws_api_gateway_method.GetApiMethod.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200,
    })
  }
}

# Set up root method
resource "aws_api_gateway_method" "GetApiMethod" {
  rest_api_id          = aws_api_gateway_rest_api.ECaaSAPI.id
  resource_id          = aws_api_gateway_rest_api.ECaaSAPI.root_resource_id
  http_method          = "GET"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.gateway_authorizer.id
  authorization_scopes = ["ecaas-api/home-energy-model"]
}

resource "aws_api_gateway_integration_response" "GetApiIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.ECaaSAPI.id
  resource_id = aws_api_gateway_rest_api.ECaaSAPI.root_resource_id
  http_method = aws_api_gateway_method.GetApiMethod.http_method
  status_code = aws_api_gateway_method_response.GetApiMethodResponse.status_code
  response_templates = {
    "application/json" = jsonencode(
      {
        "title" : "Energy Calculation as a Service",
        "version" : var.api_version,
        "links" : {
          "describedBy" : "https://dj2ahbipy3ofb.cloudfront.net/#ecaas-technical-documentation"
        }
      }
    )
  }
}

resource "aws_api_gateway_method_response" "GetApiMethodResponse" {
  rest_api_id = aws_api_gateway_rest_api.ECaaSAPI.id
  resource_id = aws_api_gateway_rest_api.ECaaSAPI.root_resource_id
  http_method = aws_api_gateway_method.GetApiMethod.http_method
  status_code = "200"
}

# hook up lambda

resource "aws_api_gateway_resource" "ECaaSBetaResource" {
  rest_api_id = aws_api_gateway_rest_api.ECaaSAPI.id
  parent_id   = aws_api_gateway_rest_api.ECaaSAPI.root_resource_id
  path_part   = "beta"
}

resource "aws_api_gateway_resource" "FHSComplianceResource" {
  rest_api_id = aws_api_gateway_rest_api.ECaaSAPI.id
  parent_id   = aws_api_gateway_resource.ECaaSBetaResource.id
  path_part   = "future-homes-standard-compliance"
}

resource "aws_api_gateway_method" "HomeEnergyModelPostMethod" {
  rest_api_id          = aws_api_gateway_rest_api.ECaaSAPI.id
  resource_id          = aws_api_gateway_resource.FHSComplianceResource.id
  http_method          = "POST"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.gateway_authorizer.id
  authorization_scopes = ["ecaas-api/home-energy-model"]
}

resource "aws_api_gateway_integration" "hem_lambda" {
  rest_api_id = aws_api_gateway_rest_api.ECaaSAPI.id
  resource_id = aws_api_gateway_method.HomeEnergyModelPostMethod.resource_id
  http_method = aws_api_gateway_method.HomeEnergyModelPostMethod.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hem_lambda.invoke_arn
}

# Set up deployment
resource "aws_api_gateway_deployment" "Deployment" {
  rest_api_id = aws_api_gateway_rest_api.ECaaSAPI.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.ECaaSAPI.id,
      aws_api_gateway_rest_api.ECaaSAPI.description,
      aws_api_gateway_rest_api.ECaaSAPI.root_resource_id,
      aws_api_gateway_method.GetApiMethod,
      aws_api_gateway_method.HomeEnergyModelPostMethod,
      aws_api_gateway_integration.GatewayIntegration.id,
      aws_api_gateway_integration_response.GetApiIntegrationResponse.response_templates,
      aws_api_gateway_integration.hem_lambda.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "DeploymentStage" {
  deployment_id        = aws_api_gateway_deployment.Deployment.id
  rest_api_id          = aws_api_gateway_rest_api.ECaaSAPI.id
  stage_name           = var.stage_name
  xray_tracing_enabled = var.xray_tracing_enabled
  depends_on           = [aws_cloudwatch_log_group.ApiGatewayLogGroup]
}

# Set up logging
resource "aws_api_gateway_method_settings" "DeploymentStageSettings" {
  rest_api_id = aws_api_gateway_rest_api.ECaaSAPI.id
  stage_name  = var.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = false // keep false otherwise Authentication access token gets written to logs
  }
}

resource "aws_cloudwatch_log_group" "ApiGatewayLogGroup" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.ECaaSAPI.id}/${var.stage_name}"
  retention_in_days = 14
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
