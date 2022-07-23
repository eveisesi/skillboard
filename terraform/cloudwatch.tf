resource "aws_cloudwatch_log_group" "apigateway_access_logs" {
  name              = "/aws/apigatewayv2/ui"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "users_handler" {
  name              = "/aws/lambda/${aws_lambda_function.users_handler.function_name}"
  retention_in_days = 3
}