resource "aws_apigatewayv2_integration" "users_handler" {
  api_id = aws_apigatewayv2_api.api.id

  connection_type        = "INTERNET"
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  payload_format_version = "2.0"
  integration_uri        = aws_lambda_function.users_handler.arn
}

resource "aws_apigatewayv2_route" "post_user_registration" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /users/login"

  target = "integrations/${aws_apigatewayv2_integration.users_handler.id}"
}

resource "aws_lambda_permission" "allow_apigw_post_users_registration" {
  statement_id  = sha1(aws_apigatewayv2_route.post_user_registration.route_key)
  function_name = aws_lambda_function.users_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/POST/users/login"
  action        = "lambda:InvokeFunction"
}
