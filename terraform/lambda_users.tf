resource "aws_lambda_function" "users_handler" {
  function_name = "users_handler"
  handler       = "main"
  role          = aws_iam_role.lambda.arn
  runtime       = "go1.x"
  s3_bucket     = aws_s3_bucket.lambda_functions.bucket
  s3_key        = "users_handler.zip"

  environment {
    variables = {
      USERS_TABLE = aws_dynamodb_table.users.name
    }
  }

  lifecycle {
    ignore_changes = [
      filename,
      s3_bucket,
      s3_key,
      s3_object_version,
      source_code_hash,
      package_type,
      image_uri,
    ]
  }
}
