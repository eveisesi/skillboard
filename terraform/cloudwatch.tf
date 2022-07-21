resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/skilltask-task"
  retention_in_days = 1
}
