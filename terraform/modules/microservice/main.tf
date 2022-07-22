data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  task_definition        = var.task_definition_revision == "" ? var.task_definition_family : "${var.task_definition_family}:${var.task_definition_revision}"
  service_discovery_name = "${var.name}-${var.environment}"

  default_log_group_name = "/ecs/${var.name}-${var.environment}"

  vpc_tag_key = coalesce(var.vpc_tag_key_override, var.project)
  vpc_id      = element(concat(data.aws_vpc.main.*.id, [var.vpc_id]), 0)
  subnet_ids  = var.enable && length(var.subnet_ids) == 0 ? data.aws_subnets.app_subnets.ids : var.subnet_ids

  default_subnet_tags = {
    app = "true"
  }
}

data "aws_vpc" "main" {
  count = var.enable && var.vpc_id == null ? 1 : 0

  filter {
    name   = "tag-key"
    values = [local.vpc_tag_key]
  }
}

# data "aws_subnet_ids" "app_subnets" {
#   count  = var.enable && length(var.subnet_ids) == 0 ? 1 : 0
#   vpc_id = var.vpc_id != null ? var.vpc_id : data.aws_vpc.main[0].id

#   tags = merge(local.default_subnet_tags, var.subnet_tag_filters)
# }

data "aws_subnets" "app_subnets" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

resource "aws_ecs_service" "service" {
  count = var.enable ? 1 : 0

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      task_definition,
      desired_count,
    ]
  }

  task_definition = local.task_definition

  name = "${var.name}-${var.environment}"
  tags = var.ecs_service_tags

  cluster                            = var.cluster
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  launch_type                       = var.launch_type
  scheduling_strategy               = var.scheduling_strategy
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  enable_ecs_managed_tags           = var.enable_ecs_managed_tags
  propagate_tags                    = var.propagate_tags
  platform_version                  = var.launch_type != "EC2" ? var.fargate_platform_version : null

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategies

    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = capacity_provider_strategy.value.base
    }
  }

  deployment_controller {
    type = var.deployment_controller_type
  }

  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_controller_type == "ECS" && var.enable_circuit_breaker ? [1] : []

    content {
      enable   = true
      rollback = var.enable_circuit_breaker_rollback
    }
  }

  network_configuration {
    subnets          = local.subnet_ids
    security_groups  = concat(aws_security_group.ecs.*.id, var.service_security_groups)
    assign_public_ip = false
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.service[0].arn
    port           = var.service_discovery_type == "SRV" ? var.container_port : 0
    container_name = var.service_discovery_type == "SRV" ? null : var.name
  }
}

resource "aws_service_discovery_service" "service" {
  count = var.enable ? 1 : 0
  name  = var.service_discovery_dns_name == "" ? local.service_discovery_name : var.service_discovery_dns_name

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl  = var.service_discovery_ttl
      type = var.service_discovery_type
    }

    routing_policy = var.service_discovery_routing_policy
  }

  health_check_custom_config {
    failure_threshold = var.service_discovery_health_check_failure_threshold
  }
}

resource "aws_security_group" "ecs" {
  count       = var.enable ? 1 : 0
  name        = "${var.name}-${var.environment}-ecs"
  description = "Allow access from the VPC to the service"
  vpc_id      = local.vpc_id

  tags = {
    Author      = "terraform"
    Environment = var.environment
    Name        = "${var.name}-${var.environment}-ecs"
    Project     = var.project
  }
}

resource "aws_security_group_rule" "egress" {
  count             = var.enable ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs[0].id

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "ecs_ingress" {
  count             = var.enable ? 1 : 0
  type              = "ingress"
  from_port         = var.container_port
  to_port           = var.container_port
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs[0].id
  self              = true
}

resource "aws_cloudwatch_log_group" "logs" {
  count             = var.enable ? 1 : 0
  name              = var.log_group_name == "" ? local.default_log_group_name : var.log_group_name
  retention_in_days = var.log_retention

  tags = {
    Environment = var.environment
  }
}
