resource "aws_apigatewayv2_api" "api" {
  name          = "skillboard-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "ui" {
  name        = "$default"
  api_id      = aws_apigatewayv2_api.api.id
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


