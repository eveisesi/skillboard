# ECS Task Terraform Module

This module creates an ECS Task Definition and IAM Task Role.  
This module is most likely used in combination with the other ecs modules.

Basic usage:

```hcl
module "task" {
  source              = "app.terraform.io/RVStandard/ecs-task/aws"
  version             = "~> 3.0"

  name                = "api
  service             = var.service
  environment         = var.workspace
  project             = var.project_name
  owner               = var.owner
  team_name           = var.team_name
  resource_allocation = "low"
}
```

Basic usage with artifactory:

```hcl
data "aws_secretsmanager_secret" "artifactory" {
  name = "artifactory/docker"
}

data "aws_secretsmanager_secret_version" "artifactory" {
  secret_id = "${data.aws_secretsmanager_secret.artifactory.id}"
}

module "task" {
  source              = "app.terraform.io/RVStandard/ecs-task/aws"
  version             = "~> 3.0"

  name                       = "api"
  service                    = var.service
  environment                = var.workspace
  project                    = var.project_name
  owner                      = var.owner
  team_name                  = var.team_name
  resource_allocation        = "low"
  docker_registry_secret_arn = data.aws_secretsmanager_secret_version.artifactory.arn
}
```

Some defaults that you may want to change:

- `container_port`: The port the application uses. This is default to `3000`, you will need to provide a different value if you would like to use a different port.
- `paramstore_resources`: By default the application will be given access to parameters on the paths `team-name-environment/*`, `team/*`, `team-name/*` and `team-environment/*`.  
If you need to give additional access, you will need to provide additional paths in the format of `arn:aws:ssm:{region}:{account_id}:parameter/{path}`.
- `secret_env_vars`: If you want to make paramstore resources available as an environment variable to the ECS task,  
you need to provide a list of maps of the form `{"name": "VAR_NAME", "valueFrom": "arn:aws:ssm:{region}:{account_id}:parameter/{path}"}`
- `docker_registry_secret_arn`: If you are using artifactory (or some other private registry) to store your images, you will need to provide the ARN of the  
  secrets manager secret that contains the username/password
- `ports`: If you need to add additional ports you can pass in a list of maps like this:
```
ports = [
  {
    containerPort = "8080"
    hostPort      = "8080"
  },
]
```

Fargate High Level [Pricing](https://aws.amazon.com/fargate/pricing/), Running 100% of Hours (On Demand / Per Month):
- Low: $8.90 per container instance
- Medium: $17.80 per container instance
- High: $35.60 per container instance
- Very High: $83.90 per container instance

Note: this does not include any load balancing or network related costs, this only includes the price for running ECS tasks on fargate.

### Custom Container Definitions

If you wish to run multiple containers as part of the same task definition, you will need to specify the definition for both containers via the `container_definitions` input as a json-encoded string.  
For example:

```hcl
module "task" {
  # ... other inputs omitted

  container_definitions = jsonencode([
    {
      cpu = 256
      memory = 512
      image = "my-image-1:latest"
      # other container def parameters
    },
    {
      cpu = 128
      memory = 256
      image = "my-image-2:latest"
      # other container def parameters
    }
  ])
}

```

## Contributing

Please read [this contributing doc](https://github.com/RedVentures/terraform-abstraction/blob/master/CONTRIBUTING.md) for details around contributing to the project.

### Issues

Issues have been disabled on this project. Please create issues [here](https://github.com/RedVentures/terraform-abstraction/issues/new/choose)


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.paramstore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.paramstore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.parameter_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asset_tag"></a> [asset\_tag](#input\_asset\_tag) | (Deprecated) CMDB / ServiceNow identifier | `string` | `null` | no |
| <a name="input_backup"></a> [backup](#input\_backup) | (Deprecated) Automation tag which defines backup schedule to apply | `string` | `null` | no |
| <a name="input_classification"></a> [classification](#input\_classification) | (Deprecated) Coded data sensitivity. Valid values are 'Romeo', 'Sieraa', 'India', 'Lima', 'Echo', 'Restricted', 'Sensitive', 'Internal', 'Limited External', 'External' | `string` | `null` | no |
| <a name="input_command"></a> [command](#input\_command) | A list of strings which represent the task command | `list(string)` | `[]` | no |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | (String) Json encoded string container definitions to use in place of the default container defintion. | `string` | `null` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The container port | `number` | `3000` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of cpu units to reserve for the container | `number` | `null` | no |
| <a name="input_docker_health_check_command"></a> [docker\_health\_check\_command](#input\_docker\_health\_check\_command) | A string array representing the command that the container runs to determine if it is healthy | `list(string)` | <pre>[<br>  "CMD-SHELL",<br>  "curl -f http://localhost/ || exit 1"<br>]</pre> | no |
| <a name="input_docker_health_check_interval"></a> [docker\_health\_check\_interval](#input\_docker\_health\_check\_interval) | The time period in seconds between each health check execution | `number` | `30` | no |
| <a name="input_docker_health_check_retries"></a> [docker\_health\_check\_retries](#input\_docker\_health\_check\_retries) | The number of times to retry a failed health check before the container is considered unhealthy | `number` | `3` | no |
| <a name="input_docker_health_check_start_period"></a> [docker\_health\_check\_start\_period](#input\_docker\_health\_check\_start\_period) | The optional grace period within which to provide containers time to bootstrap before failed health checks count towards the maximum number of retries | `number` | `5` | no |
| <a name="input_docker_health_check_timeout"></a> [docker\_health\_check\_timeout](#input\_docker\_health\_check\_timeout) | The time period in seconds to wait for a health check to succeed before it is considered a failure | `number` | `5` | no |
| <a name="input_docker_labels"></a> [docker\_labels](#input\_docker\_labels) | A key/value map of labels to add to the container | `map(string)` | `null` | no |
| <a name="input_docker_registry_secret_arn"></a> [docker\_registry\_secret\_arn](#input\_docker\_registry\_secret\_arn) | The ARN of the Secrets Manager secret that authenticates against the private docker registry, i.e. artifactory | `string` | `null` | no |
| <a name="input_ecr_repositories"></a> [ecr\_repositories](#input\_ecr\_repositories) | List of additional ECR repositories the role should have access to. Should be the ARN of the repository | `list(string)` | `[]` | no |
| <a name="input_efs_volumes"></a> [efs\_volumes](#input\_efs\_volumes) | An EFS-managed volume that is mounted under /var/lib/docker/volumes on the container instance | <pre>list(object({<br>    name = string<br>    efs_volume_configuration = list(object({<br>      file_system_id = string<br>      root_directory = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Whether or not to create this module | `bool` | `true` | no |
| <a name="input_enable_docker_health_check"></a> [enable\_docker\_health\_check](#input\_enable\_docker\_health\_check) | Whether or not to enable the docker health check on the task | `bool` | `false` | no |
| <a name="input_entry_point"></a> [entry\_point](#input\_entry\_point) | The docker container entry point | `list(string)` | `[]` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | A list of maps that represent environment variables to be placed on the task definition | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment to which the application belongs. | `string` | n/a | yes |
| <a name="input_essential"></a> [essential](#input\_essential) | If the essential parameter of a container is marked as true, and that container fails or stops for any reason, all other containers that are part of the task are stopped. If the essential parameter of a container is marked as false, then its failure does not affect the rest of the containers in a task | `bool` | `true` | no |
| <a name="input_expiration"></a> [expiration](#input\_expiration) | (Deprecated) Date resource should be removed or reviewed | `string` | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | The docker image name, e.g nginx:latest | `string` | `null` | no |
| <a name="input_log_options"></a> [log\_options](#input\_log\_options) | Optionally specify additional logging options | `map(string)` | `{}` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The number of MiB of memory to reserve for the container | `number` | `null` | no |
| <a name="input_mount_points"></a> [mount\_points](#input\_mount\_points) | The mount points for data volumes in your container | <pre>list(object({<br>    sourceVolume  = string<br>    containerPath = string<br>    readOnly      = bool<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of your application | `string` | n/a | yes |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host | `string` | `"awsvpc"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | (Deprecated) First level contact for the resource. This can be email address or team alias | `string` | `null` | no |
| <a name="input_paramstore_resources"></a> [paramstore\_resources](#input\_paramstore\_resources) | Additional param store resources writen with chamber that the application needs access to | `list(string)` | `[]` | no |
| <a name="input_partner"></a> [partner](#input\_partner) | (Deprecated) Business Unit for which the application is deployed | `string` | `null` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | The docker container ports | <pre>list(object({<br>    hostPort      = number<br>    containerPort = number<br>    protocol      = string<br>  }))</pre> | `[]` | no |
| <a name="input_project"></a> [project](#input\_project) | Project to which the application belongs | `string` | n/a | yes |
| <a name="input_provisioner"></a> [provisioner](#input\_provisioner) | (Deprecated) Tool used to provision the resource | `string` | `"terraform://terraform-aws-ecs-task"` | no |
| <a name="input_requires_capabilities"></a> [requires\_capabilities](#input\_requires\_capabilities) | A set of launch types required by the task. The valid values are EC2 and FARGATE | `list(string)` | <pre>[<br>  "FARGATE"<br>]</pre> | no |
| <a name="input_resource_allocation"></a> [resource\_allocation](#input\_resource\_allocation) | The amount of compute/memory resources required by the service ('low', 'medium', 'high', 'very-high') | `string` | `""` | no |
| <a name="input_secret_env_vars"></a> [secret\_env\_vars](#input\_secret\_env\_vars) | A list of maps that represent Parameter Store secrets to be made available as environment variables | <pre>list(object({<br>    name      = string<br>    valueFrom = string<br>  }))</pre> | `[]` | no |
| <a name="input_service"></a> [service](#input\_service) | (Deprecated) Function of the resoucrce | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optionally specify additional tags to add to the ECS Service. Please reference the [AWS Implementation Guide](https://security.rvdocs.io/guides/aws-implementation.html#required-tags) for more details on what tags are required | `map(string)` | `{}` | no |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | The team to which the app belongs. Used as the chamber path prefix. | `string` | n/a | yes |
| <a name="input_ulimits"></a> [ulimits](#input\_ulimits) | A list of ulimits to set in the container | <pre>list(object({<br>    name      = string<br>    softLimit = number<br>    hardLimit = number<br>  }))</pre> | `null` | no |
| <a name="input_version_tag"></a> [version\_tag](#input\_version\_tag) | (Deprecated) Distinguish between different versions of the resource | `string` | `null` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | A Docker-managed volume that is created under /var/lib/docker/volumes on the container instance | <pre>list(object({<br>    name      = string<br>    host_path = string<br>    docker_volume_configuration = list(object({<br>      autoprovison = bool<br>      driver       = string<br>      driver_opts  = map(string)<br>      labels       = map(string)<br>      autoprovison = bool<br>    }))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the task definition |
| <a name="output_name"></a> [name](#output\_name) | The task definition name |
| <a name="output_rendered_container_definition"></a> [rendered\_container\_definition](#output\_rendered\_container\_definition) | The JSON container definition |
| <a name="output_revision"></a> [revision](#output\_revision) | The revision number of the task definition |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | The ARN of the IAM task role |
| <a name="output_task_role_name"></a> [task\_role\_name](#output\_task\_role\_name) | The name of the IAM task role |
<!-- END_TF_DOCS -->