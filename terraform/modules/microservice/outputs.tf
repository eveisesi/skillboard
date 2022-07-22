output "security_group_id" {
  value       = element(concat(aws_security_group.ecs.*.id, [""]), 0)
  description = "The ID of the security group attached to the ECS service"
}

output "service_discovery_id" {
  value       = element(concat(aws_service_discovery_service.service.*.id, [""]), 0)
  description = "The ID of the service discovery service"
}

output "service_discovery_arn" {
  value       = element(concat(aws_service_discovery_service.service.*.arn, [""]), 0)
  description = "The ARN of the service discovery application"
}

output "arn" {
  value       = element(concat(aws_ecs_service.service.*.id, [""]), 0)
  description = "The ID of the ECS service"
}

output "name" {
  value       = element(concat(aws_ecs_service.service.*.name, [""]), 0)
  description = "The name of the ECS service"
}

output "cluster" {
  value       = element(concat(aws_ecs_service.service.*.cluster, [""]), 0)
  description = "The name of the cluster the ECS service is running on"
}
