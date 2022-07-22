resource "aws_apigatewayv2_api" "ui" {
  name          = "skillboard-ui"
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = true
    allow_headers     = ["*"]
    allow_methods     = ["*"]
    expose_headers    = ["*"]
    allow_origins = [
      "https://skillboard2.eveisesi.space",
      "http://localhost:3000"
    ]
  }
}

resource "aws_apigatewayv2_stage" "ui" {
  name        = "$default"
  api_id      = aws_apigatewayv2_api.ui.id
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigateway_access_logs.arn
    format = jsonencode({
      httpMethod              = "$context.httpMethod"
      integrationErrorMessage = "$context.integrationErrorMessage"
      ip                      = "$context.identity.sourceIp"
      protocol                = "$context.protocol"
      requestId               = "$context.requestId"
      requestTime             = "$context.requestTime"
      responseLength          = "$context.responseLength"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
    })
  }
}

resource "aws_apigatewayv2_route" "ui" {
  api_id    = aws_apigatewayv2_api.ui.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.ui.id}"
}

resource "aws_apigatewayv2_vpc_link" "ui" {
  name               = "ui"
  security_group_ids = [module.nuxt_ui.security_group_id]
  subnet_ids         = module.vpc.app_subnet_ids
}

resource "aws_apigatewayv2_integration" "ui" {
  api_id             = aws_apigatewayv2_api.ui.id
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.ui.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = module.nuxt_ui.service_discovery_arn
}
