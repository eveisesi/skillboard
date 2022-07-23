resource "aws_cloudwatch_log_group" "apigateway_access_logs" {
  name              = "/aws/apigatewayv2/ui"
  retention_in_days = 1
}
