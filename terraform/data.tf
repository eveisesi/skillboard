# data "aws_availability_zones" "available" {}
# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}

# data "aws_iam_policy_document" "task_assume_role" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "sts:AssumeRole"
#     ]
#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }

# data "aws_iam_policy_document" "task_ecr" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:BatchGetImage",
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:GetAuthorizationToken"
#     ]
#     resources = ["*"]
#   }
# }

# data "aws_iam_policy_document" "task_cloudwatch" {
#   statement {
#     effect  = "Allow"
#     actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
#     resources = [
#       "${aws_cloudwatch_log_group.ecs.arn}:*",
#     ]
#   }
# }
