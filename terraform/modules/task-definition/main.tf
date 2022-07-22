data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  default_env_vars = [
    {
      name  = "SERVICE_NAME"
      value = var.name
    },
    {
      name  = "APP_ENV"
      value = var.environment
    },
  ]

  env_vars = concat(local.default_env_vars, var.env_vars)

  ports = [
    {
      containerPort = var.container_port
      hostPort      = var.network_mode == "awsvpc" ? var.container_port : 0
    },
  ]

  health_check = {
    retries     = var.docker_health_check_retries
    command     = var.docker_health_check_command
    timeout     = var.docker_health_check_timeout
    interval    = var.docker_health_check_interval
    startPeriod = var.docker_health_check_start_period
  }

  port_mappings = concat(local.ports, var.ports)

  memory = coalesce(
    var.memory,
    lookup({
      "low"       = 512
      "medium"    = 1024
      "high"      = 2048
      "very-high" = 8192
    }, var.resource_allocation, null),
    512,
  )

  cpu = coalesce(
    var.cpu,
    lookup({
      "low"       = 256
      "medium"    = 512
      "high"      = 1024
      "very-high" = 2048
    }, var.resource_allocation, null),
    256,
  )

  paramstore_resources = [
    "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.team_name}/*",
    "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.team_name}-${var.environment}/*",
    "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.team_name}-${var.name}-${var.environment}/*",
    "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.team_name}-${var.name}/*",
  ]

  image         = var.image == null ? local.default_image : var.image
  default_image = var.docker_registry_secret_arn == null ? "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.name}" : "docker.registry.rvapps.io/${var.name}"

  default_tags = {
    Name           = "${var.name}-${var.environment}"
    Service        = var.service
    Environment    = var.environment
    Version        = var.version_tag
    Provisioner    = var.provisioner
    Expiration     = var.expiration
    Asset_Tag      = var.asset_tag
    Partner        = var.partner
    Project        = var.project
    Owner          = var.owner
    Classification = var.classification
    Backup         = var.backup
  }

  tags = merge(local.default_tags, var.tags)

  default_log_options = {
    "awslogs-group" = "/ecs/${var.name}-${var.environment}"
    "awslogs-region" : data.aws_region.current.name
    "awslogs-stream-prefix" = var.name
  }

  container_definition = {
    cpu          = local.cpu
    environment  = local.env_vars
    secrets      = var.secret_env_vars
    essential    = var.essential
    command      = var.command,
    image        = local.image
    memory       = local.memory
    name         = "${var.name}-${var.environment}"
    ulimits      = var.ulimits
    portMappings = var.container_port == 0 && length(var.ports) == 0 ? null : local.port_mappings
    entryPoint   = var.entry_point
    mountPoints  = var.mount_points
    repositoryCredentials = var.docker_registry_secret_arn != null ? {
      credentialsParameter = var.docker_registry_secret_arn
    } : null
    healthCheck = var.enable_docker_health_check ? local.health_check : null
    logConfiguration = {
      logDriver = "awslogs"
      options   = merge(local.default_log_options, var.log_options)
    }
    dockerLabels = var.docker_labels
  }
}

resource "aws_ecs_task_definition" "main" {
  count              = var.enable ? 1 : 0
  family             = "${var.name}-${var.environment}"
  task_role_arn      = aws_iam_role.task_role[0].arn
  execution_role_arn = aws_iam_role.task_role[0].arn
  network_mode       = var.network_mode

  cpu    = contains(var.requires_capabilities, "EC2") ? "" : local.cpu
  memory = contains(var.requires_capabilities, "EC2") ? "" : local.memory

  requires_compatibilities = var.requires_capabilities

  lifecycle {
    create_before_destroy = true
  }

  dynamic "volume" {
    for_each = var.volumes

    content {
      host_path = lookup(volume.value, "host_path", null)
      name      = volume.value.name

      dynamic "docker_volume_configuration" {
        for_each = lookup(volume.value, "docker_volume_configuration", [])

        content {
          autoprovision = lookup(docker_volume_configuration.value, "autoprovision", null)
          driver        = lookup(docker_volume_configuration.value, "driver", null)
          driver_opts   = lookup(docker_volume_configuration.value, "driver_opts", null)
          labels        = lookup(docker_volume_configuration.value, "labels", null)
          scope         = lookup(docker_volume_configuration.value, "scope", null)
        }
      }
    }
  }

  dynamic "volume" {
    for_each = var.efs_volumes

    content {
      name = volume.value.name

      dynamic "efs_volume_configuration" {
        for_each = lookup(volume.value, "efs_volume_configuration", [])

        content {
          file_system_id = lookup(efs_volume_configuration.value, "file_system_id", null)
          root_directory = lookup(efs_volume_configuration.value, "root_directory", null)
        }
      }
    }
  }

  container_definitions = coalesce(var.container_definitions, jsonencode([local.container_definition]))

  tags = local.tags
}

data "aws_iam_policy_document" "task_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_role" {
  count              = var.enable ? 1 : 0
  name               = "${var.name}-${var.environment}-task-role-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.task_role.json
  tags               = local.tags
}

data "aws_iam_policy_document" "fargate" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "ecr" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]

    resources = concat(
      ["arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.name}"],
      var.ecr_repositories,
    )
  }
}

resource "aws_iam_role_policy" "fargate" {
  count  = var.enable ? 1 : 0
  name   = "fargate-logs-ecr"
  role   = aws_iam_role.task_role[0].name
  policy = data.aws_iam_policy_document.fargate.json
}

resource "aws_iam_role_policy" "ecr" {
  count  = var.enable ? 1 : 0
  name   = "fargate-ecr"
  role   = aws_iam_role.task_role[0].name
  policy = data.aws_iam_policy_document.ecr.json
}

# resource "aws_iam_role_policy" "paramstore" {
#   count  = var.enable ? 1 : 0
#   name   = "paramstore-get"
#   role   = aws_iam_role.task_role[0].name
#   policy = data.aws_iam_policy_document.paramstore.json
# }
