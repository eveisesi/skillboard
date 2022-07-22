variable "environment" {
  type        = string
  description = "Environment to which the application belongs"
}

variable "name" {
  type        = string
  description = "The name of your application"
}

variable "project" {
  type        = string
  description = "Project to which the application belongs."
}

variable "cluster" {
  type        = string
  description = "The cluster name where the service should be placed."
}

variable "task_definition_family" {
  type        = string
  description = "The family and revision (family:revision) or just the family if you want to use the latest revision, that you want to run in your service"
}

variable "task_definition_revision" {
  type        = string
  description = "The task definition revision that you want to  create your service with. Will only be recognized on initial creation"
  default     = ""
}

variable "namespace_id" {
  type        = string
  description = "The ID of the namespace to use for DNS configuration"
}

variable "service_security_groups" {
  type        = list(string)
  description = "List of security groups to attach to the ECS service"
  default     = []
}

variable "desired_count" {
  type        = number
  description = "The desired task count for the service"
  default     = 2
}

variable "launch_type" {
  type        = string
  description = "The launch type on which to run your service. The valid values are EC2 and FARGATE"
  default     = "FARGATE"
}

variable "scheduling_strategy" {
  type        = string
  description = "The scheduling strategy to use for the service. The valid values are REPLICA and DAEMON"
  default     = "REPLICA"
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "Lower limit (% of desired_count) of # of running tasks during a deployment"
  default     = 100
}

variable "deployment_maximum_percent" {
  type        = number
  description = "Upper limit (% of desired_count) of # of running tasks during a deployment"
  default     = 200
}

variable "health_check_grace_period_seconds" {
  type        = number
  default     = 0
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200"
}

variable "service_discovery_type" {
  type        = string
  default     = "A"
  description = "The Type of service discovery record to create, valid values are 'SRV' or 'A'"
}

variable "service_discovery_ttl" {
  type        = number
  default     = 10
  description = "The TTL for the service discovery service"
}

variable "container_port" {
  type        = number
  description = "The container port"
  default     = 3000
}

variable "enable" {
  type        = bool
  description = "Whether or not to create this module"
  default     = true
}

variable "service_discovery_dns_name" {
  type        = string
  description = "The DNS name of the service"
  default     = ""
}

variable "service_discovery_routing_policy" {
  type        = string
  description = "The routing policy that you want to apply to all records that Route 53 creates when you register an instance and specify the service. Valid Values: MULTIVALUE, WEIGHTED"
  default     = "MULTIVALUE"
}

variable "service_discovery_health_check_failure_threshold" {
  type        = number
  description = "The number of consecutive health checks. Maximum value of 10"
  default     = 1
}

variable "log_group_name" {
  type        = string
  description = "Custom cloudwatch log group name, if desired"
  default     = ""
}

variable "subnet_tag_filters" {
  type        = map(string)
  description = "A map of additional tags to filter subnets on."
  default     = {}
}

variable "capacity_provider_strategies" {
  description = "The capacity provider strategies to use for a service."
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = number
  }))
  default = []
}

variable "propagate_tags" {
  type        = string
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION"
  default     = ""
}

variable "enable_ecs_managed_tags" {
  type        = bool
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service"
  default     = false
}

variable "ecs_service_tags" {
  type        = map(string)
  description = "Optionally specify additional tags to add to the ECS Service only, typically used for scheduling resources."
  default     = null
}

variable "fargate_platform_version" {
  type        = string
  description = "The platform version on which to run your service. Only applicable for launch_type set to FARGATE. Defaults to LATEST"
  default     = "LATEST"
}

variable "log_retention" {
  type        = string
  description = "The time in days to keep Cloudwatch Logs. If this is set to 0 the logs will be retained indefinitely."
  default     = "14"
}

variable "vpc_id" {
  description = "An optional vpc_id to provide. This overrides data lookups and you must also provide subnet_ids"
  default     = null
}

variable "subnet_ids" {
  description = "An optional list of subnet_ids to provide. This overrides data lookups and you must also provide vpc_id"
  default     = []
  type        = set(string)
}

variable "vpc_tag_key_override" {
  type        = string
  description = "The tag-key to override standard VPC lookup, defaults to var.project"
  default     = null
}

variable "deployment_controller_type" {
  type        = string
  description = "Type of deployment controller. Valid values: CODE_DEPLOY, ECS"
  default     = "ECS"
}

variable "enable_circuit_breaker" {
  type        = bool
  description = "If true, enables the ECS Circuit Breaker functionality. Has no effect if deployment_controller_type is CODE_DEPLOY."
  default     = true
}

variable "enable_circuit_breaker_rollback" {
  type        = bool
  description = "If set to true, deployments that fail the circuit breaker will automatically be rolled back. See [the circuit breaker docs](https://aws.amazon.com/blogs/containers/announcing-amazon-ecs-deployment-circuit-breaker/) for more information."
  default     = false
}
