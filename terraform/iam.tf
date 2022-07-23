resource "aws_iam_role" "lambda" {
  name               = "lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
  }
}

resource "aws_iam_role_policy" "lambda_dynamo" {
  name   = "lambda_dynamo"
  role   = aws_iam_role.lambda.name
  policy = data.aws_iam_policy_document.lambda_dynamo.json
}

data "aws_iam_policy_document" "lambda_dynamo" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
    ]
    resources = [
      "${aws_dynamodb_table.auth_attempts.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "lambda_cloudwatch" {
  name   = "lambda_cloudwatch"
  role   = aws_iam_role.lambda.name
  policy = data.aws_iam_policy_document.lambda_cloudwatch.json
}

data "aws_iam_policy_document" "lambda_cloudwatch" {
  statement {
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      "${aws_cloudwatch_log_group.users_handler.arn}:*",
    ]
  }
}