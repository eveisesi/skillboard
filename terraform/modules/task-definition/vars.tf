variable "team_name" {
  type        = string
  description = "The team to which the app belongs. Used as the chamber path prefix."
}

variable "image" {
  type        = string
  description = "The docker image name, e.g nginx:latest"
  default     = null
}

variable "cpu" {
  type        = number
  description = "The number of cpu units to reserve for the container"
  default     = null
}

variable "paramstore_resources" {
  type        = list(string)
  default     = []
  description = "Additional param store resources writen with chamber that the application needs access to"
}

variable "env_vars" { # [{ "name": name, "value": value }]
  type = list(object({
    name  = string
    value = string
  }))

  description = "A list of maps that represent environment variables to be placed on the task definition"
  default     = []
}

variable "secret_env_vars" { # [{ "name": env_variable_name, "valueFrom": "arn:aws:ssm:region:aws_account_id:parameter/parameter_name"}]
  type = list(object({
    name      = string
    valueFrom = string
  }))

  description = "A list of maps that represent Parameter Store secrets to be made available as environment variables"
  default     = []
}

variable "command" { # ["--key=foo","--port=bar"]
  type        = list(string)
  description = "A list of strings which represent the task command"
  default     = []
}

variable "entry_point" {
  type        = list(string)
  description = "The docker container entry point"
  default     = []
}

variable "ports" {
  type = list(object({
    hostPort      = number
    containerPort = number
    protocol      = string
  }))

  description = "The docker container ports"
  default     = []
}

variable "container_port" {
  type        = number
  description = "The container port"
  default     = 3000
}

variable "ulimits" {
  type = list(object({
    name      = string
    softLimit = number
    hardLimit = number
  }))

  description = "A list of ulimits to set in the container"
  default     = null
}

variable "essential" {
  type        = bool
  description = "If the essential parameter of a container is marked as true, and that container fails or stops for any reason, all other containers that are part of the task are stopped. If the essential parameter of a container is marked as false, then its failure does not affect the rest of the containers in a task"
  default     = true
}

variable "mount_points" {
  type = list(object({
    sourceVolume  = string
    containerPath = string
    readOnly      = bool
  }))

  description = "The mount points for data volumes in your container"
  default     = []
}

variable "volumes" {
  type = list(object({
    name      = string
    host_path = string
    docker_volume_configuration = list(object({
      autoprovison = bool
      driver       = string
      driver_opts  = map(string)
      labels       = map(string)
      autoprovison = bool
    }))
  }))

  description = "A Docker-managed volume that is created under /var/lib/docker/volumes on the container instance"
  default     = []
}

variable "efs_volumes" {
  type = list(object({
    name = string
    efs_volume_configuration = list(object({
      file_system_id = string
      root_directory = string
    }))
  }))

  description = "An EFS-managed volume that is mounted under /var/lib/docker/volumes on the container instance"
  default     = []
}

variable "container_definitions" {
  type        = string
  description = "(String) Json encoded string container definitions to use in place of the default container defintion."
  default     = null
}

variable "memory" {
  type        = number
  description = "The number of MiB of memory to reserve for the container"
  default     = null
}

variable "requires_capabilities" {
  type        = list(string)
  description = "A set of launch types required by the task. The valid values are EC2 and FARGATE"
  default     = ["FARGATE"]
}

variable "network_mode" {
  type        = string
  description = "The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host"
  default     = "awsvpc"
}

variable "resource_allocation" {
  type        = string
  description = "The amount of compute/memory resources required by the service ('low', 'medium', 'high', 'very-high')"
  default     = ""
}

variable "enable_docker_health_check" {
  type        = bool
  description = "Whether or not to enable the docker health check on the task"
  default     = false
}

variable "docker_health_check_retries" {
  type        = number
  description = "The number of times to retry a failed health check before the container is considered unhealthy"
  default     = 3
}

variable "docker_health_check_command" {
  type        = list(string)
  description = "A string array representing the command that the container runs to determine if it is healthy"
  default     = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
}

variable "docker_health_check_timeout" {
  type        = number
  description = "The time period in seconds to wait for a health check to succeed before it is considered a failure"
  default     = 5
}

variable "docker_health_check_interval" {
  type        = number
  description = "The time period in seconds between each health check execution"
  default     = 30
}

variable "docker_health_check_start_period" {
  type        = number
  description = "The optional grace period within which to provide containers time to bootstrap before failed health checks count towards the maximum number of retries"
  default     = 5
}

variable "docker_labels" {
  type        = map(string)
  description = "A key/value map of labels to add to the container"
  default     = null
}

variable "enable" {
  type        = bool
  description = "Whether or not to create this module"
  default     = true
}

variable "ecr_repositories" {
  type        = list(string)
  description = "List of additional ECR repositories the role should have access to. Should be the ARN of the repository"
  default     = []
}

variable "docker_registry_secret_arn" {
  type        = string
  description = "The ARN of the Secrets Manager secret that authenticates against the private docker registry, i.e. artifactory"
  default     = null
}

variable "log_options" {
  type        = map(string)
  description = "Optionally specify additional logging options"
  default     = {}
}

/*
* Begin CNN Tag Variables
*/

variable "tags" {
  type        = map(string)
  description = "Optionally specify additional tags to add to the ECS Service. Please reference the [AWS Implementation Guide](https://security.rvdocs.io/guides/aws-implementation.html#required-tags) for more details on what tags are required"
  default     = {}
}

variable "name" {
  type        = string
  description = "The name of your application"
}

variable "service" {
  type        = string
  description = "(Deprecated) Function of the resoucrce"
  default     = null
}

variable "environment" {
  type        = string
  description = "Environment to which the application belongs."
}

variable "version_tag" {
  type        = string
  description = "(Deprecated) Distinguish between different versions of the resource"
  default     = null
}

variable "provisioner" {
  type        = string
  description = "(Deprecated) Tool used to provision the resource"
  default     = "terraform://terraform-aws-ecs-task"
}

variable "expiration" {
  type        = string
  description = "(Deprecated) Date resource should be removed or reviewed"
  default     = null
}

variable "asset_tag" {
  type        = string
  description = "(Deprecated) CMDB / ServiceNow identifier"
  default     = null
}

variable "partner" {
  type        = string
  description = "(Deprecated) Business Unit for which the application is deployed"
  default     = null
}

variable "project" {
  type        = string
  description = "Project to which the application belongs"
}

variable "owner" {
  type        = string
  description = "(Deprecated) First level contact for the resource. This can be email address or team alias"
  default     = null
}

variable "classification" {
  type        = string
  description = "(Deprecated) Coded data sensitivity. Valid values are 'Romeo', 'Sieraa', 'India', 'Lima', 'Echo', 'Restricted', 'Sensitive', 'Internal', 'Limited External', 'External'"
  default     = null
}

variable "backup" {
  type        = string
  description = "(Deprecated) Automation tag which defines backup schedule to apply"
  default     = null
}

/*
* End CNN Tag Variables
*/
