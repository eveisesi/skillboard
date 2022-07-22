output "name" {
  description = "The task definition name"
  value       = element(concat(aws_ecs_task_definition.main.*.family, [""]), 0)
}

output "arn" {
  description = "The ARN of the task definition"
  value       = element(concat(aws_ecs_task_definition.main.*.arn, [""]), 0)
}

output "revision" {
  description = "The revision number of the task definition"
  value       = element(concat(aws_ecs_task_definition.main.*.revision, [""]), 0)
}

output "task_role_name" {
  description = "The name of the IAM task role"
  value       = element(concat(aws_iam_role.task_role.*.name, [""]), 0)
}

output "task_role_arn" {
  value       = element(concat(aws_iam_role.task_role.*.arn, [""]), 0)
  description = "The ARN of the IAM task role"
}

output "rendered_container_definition" {
  value       = jsonencode([local.container_definition])
  description = "The JSON container definition"

  # environment variables can potentially be sensitive, so we should ensure
  # this is marked as sensitive regardless
  sensitive = true
}
