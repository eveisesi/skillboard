# resource "aws_iam_role" "task" {
#   name               = "skillboard-task-role"
#   assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
# }

# resource "aws_iam_role_policy" "task_ecr" {
#   name   = "skillboard-task-ecr"
#   role   = aws_iam_role.task.name
#   policy = data.aws_iam_policy_document.task_ecr.json
# }

# resource "aws_iam_role_policy" "task_cloudwatch" {
#   name   = "skillboard-task-cloudwatch"
#   role   = aws_iam_role.task.name
#   policy = data.aws_iam_policy_document.task_cloudwatch.json
# }

