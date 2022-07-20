resource "aws_ecs_cluster" "skillboard" {
  name = "skillboard"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "skillboard" {
  name            = "skillboard"
  cluster         = aws_ecs_cluster.skillboard.id
  task_definition = aws_ecs_task_definition.skillboard_task.arn
  desired_count   = 1

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  health_check_grace_period_seconds  = 0
  enable_ecs_managed_tags            = false

  propagate_tags   = "SERVICE"
  platform_version = "LATEST"

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets          = [aws_subnet.app.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.skillboard_nuxt.arn
    port         = 3000
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      task_definition,
      desired_count,
    ]
  }
}



resource "aws_ecs_task_definition" "skillboard_task" {
  family                   = "skillboard-task"
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.task.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  container_definitions = jsonencode([
    {
      name      = "task"
      image     = "${aws_ecr_repository.skillboard_ui.repository_url}:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])

  lifecycle {
    create_before_destroy = true
  }
}

