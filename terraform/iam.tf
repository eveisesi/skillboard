resource "aws_iam_role" "task" {
  name               = "skillboard-task-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
}

data "aws_iam_policy_document" "task_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "task_ecr" {
  name   = "skillboard-task-ecr"
  role   = aws_iam_role.task.name
  policy = data.aws_iam_policy_document.task_ecr.json
}

data "aws_iam_policy_document" "task_ecr" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role_policy" "task_cloudwatch" {
  name   = "skillboard-task-cloudwatch"
  role   = aws_iam_role.task.name
  policy = data.aws_iam_policy_document.task_cloudwatch.json
}

data "aws_iam_policy_document" "task_cloudwatch" {
  statement {
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      "${aws_cloudwatch_log_group.ecs.arn}:*",
    ]
  }
}
