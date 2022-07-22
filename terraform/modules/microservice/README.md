# ECS Microservice Terraform Module

This module should be used if you want to create a serivce using
[ECS Service Discovery](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html)  
The module creates an ecs service and service discovery service. This module should be used along with the terraform-aws-ecs-task module  
to create the task definition and role that the service will reference.

This module requires that a service discovery provate dns namespace already be created. This can  
be created using the [servicediscovery-private-namespace](https://github.com/RedVentures/terraform-aws-servicediscovery-private-namespace) module.

Usage:

```hcl
module "microservice" {
  source       = "app.terraform.io/RVStandard/ecs-microservice/aws"
  version      = "~> 2.0"

  name                   = "microservice"
  cluster                = "rv-example-${var.workspace}"
  project                = var.project_name
  environment            = var.workspace
  task_definition_family = module.task.name
  namespace_id           = module.service_discovery_service.example.id
}
```

Some defaults that you may want to change:

- `container_port`: The port the application uses. This is default to `3000`, you will need to provide a different value if you would like to use a different port.
- `service_security_groups`: List of additional security groups to attach to the ECS service. If your service  
needs access to a RDS database for example, you would put the ID of the RDS security group here so that your  
service can communicate with the database.
`desired_count`: By default this is set to 2. You can increase this if you want to run more tasks in your  
service, but you should not go lower than 2.
- `enable_circuit_breaker_rollback`: If set to true, deployments that trip the ecs circuit breaker will automatically be rolled back. See the [ECS Circuit Breaker](https://aws.amazon.com/blogs/containers/announcing-amazon-ecs-deployment-circuit-breaker/) blog post for more information.
- `capacity_provider_strategies`: List of capacity provider strategies to use for the service.  
This allows you to utilize things like Fargate Spot instances. Please see this [guide](capacity_provider_strategies_migration.md) before using this feature.  
See [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html) for more information regarding capacity provider strategies.  
 Example:
```hcl
    capacity_provider_strategies = [
      {
        capacity_provider = "FARGATE_SPOT"
        weight            = 100
        base              = 0
      }
    ]
    launch_type = null
```
*NOTE* Using `capacity_provider_strategies` also requires `launch_type` to be set to null.
*BEWARE* By using `launch_type` set to null without `capacity_provider_strategies` set will use the clusters default capacity strategy,  
due to [an open issue with the aws-terraform-provider](https://github.com/terraform-providers/terraform-provider-aws/issues/11395), this will result in planned changes every time.

## Things to Note

Because of some oddities in the way Terraform deals with the `aws_ecs_service` and `aws_ecs_task_definition` resources  
we have configured the `aws_ecs_service` resource to not detect changes on the `task_definition`, and `desired_count`  
If you make any changes to these attributes after the service has been created, Terraform will not recognize those changes.  
If you need to update these attributes you have the following options:

- `task_definition`: If you need to make updates to the task definition, you can make those updates to the `ecs-task` module.  
  The new task definition that is created will be attached to the service during the next deployment of your application.  
  Due to the way Terraform manages the task definition resource, you should do a deployment as soon after updating the task  
  definition as possible.
- `desired_count`: The desired count can be updated by attaching an autoscaling policy to your service.

## Contributing

Please read [this contributing doc](https://github.com/RedVentures/terraform-abstraction/blob/master/CONTRIBUTING.md) for details around contributing to the project.

### Issues

Issues have been disabled on this project. Please create issues [here](https://github.com/RedVentures/terraform-abstraction/issues/new/choose)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| capacity_provider_strategies | The capacity provider strategies to use for a service. | <pre>list(object({<br>    capacity_provider = string<br>    weight            = number<br>    base              = number<br>  }))</pre> | `[]` | no |
| cluster | The cluster name where the service should be placed. | `string` | n/a | yes |
| container_port | The container port | `number` | `3000` | no |
| deployment_controller_type | Type of deployment controller. Valid values: CODE_DEPLOY, ECS | `string` | `"ECS"` | no |
| deployment_maximum_percent | Upper limit (% of desired_count) of # of running tasks during a deployment | `number` | `200` | no |
| deployment_minimum_healthy_percent | Lower limit (% of desired_count) of # of running tasks during a deployment | `number` | `100` | no |
| desired_count | The desired task count for the service | `number` | `2` | no |
| ecs_service_tags | Optionally specify additional tags to add to the ECS Service only, typically used for scheduling resources. | `map(string)` | `null` | no |
| enable | Whether or not to create this module | `bool` | `true` | no |
| enable_circuit_breaker | If true, enables the ECS Circuit Breaker functionality. Has no effect if deployment_controller_type is CODE_DEPLOY. | `bool` | `true` | no |
| enable_circuit_breaker_rollback | If set to true, deployments that fail the circuit breaker will automatically be rolled back. See [the circuit breaker docs](https://aws.amazon.com/blogs/containers/announcing-amazon-ecs-deployment-circuit-breaker/) for more information. | `bool` | `false` | no |
| enable_ecs_managed_tags | Specifies whether to enable Amazon ECS managed tags for the tasks within the service | `bool` | `false` | no |
| environment | Environment to which the application belongs | `string` | n/a | yes |
| fargate_platform_version | The platform version on which to run your service. Only applicable for launch_type set to FARGATE. Defaults to LATEST | `string` | `"LATEST"` | no |
| health_check_grace_period_seconds | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200 | `number` | `0` | no |
| launch_type | The launch type on which to run your service. The valid values are EC2 and FARGATE | `string` | `"FARGATE"` | no |
| log_group_name | Custom cloudwatch log group name, if desired | `string` | `""` | no |
| log_retention | The time in days to keep Cloudwatch Logs. If this is set to 0 the logs will be retained indefinitely. | `string` | `"14"` | no |
| name | The name of your application | `string` | n/a | yes |
| namespace_id | The ID of the namespace to use for DNS configuration | `string` | n/a | yes |
| project | Project to which the application belongs. | `string` | n/a | yes |
| propagate_tags | Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION | `string` | `""` | no |
| scheduling_strategy | The scheduling strategy to use for the service. The valid values are REPLICA and DAEMON | `string` | `"REPLICA"` | no |
| service_discovery_dns_name | The DNS name of the service | `string` | `""` | no |
| service_discovery_health_check_failure_threshold | The number of consecutive health checks. Maximum value of 10 | `number` | `1` | no |
| service_discovery_routing_policy | The routing policy that you want to apply to all records that Route 53 creates when you register an instance and specify the service. Valid Values: MULTIVALUE, WEIGHTED | `string` | `"MULTIVALUE"` | no |
| service_discovery_ttl | The TTL for the service discovery service | `number` | `10` | no |
| service_discovery_type | The Type of service discovery record to create, valid values are 'SRV' or 'A' | `string` | `"A"` | no |
| service_security_groups | List of security groups to attach to the ECS service | `list(string)` | `[]` | no |
| subnet_ids | An optional list of subnet_ids to provide. This overrides data lookups and you must also provide vpc_id | `set(string)` | `[]` | no |
| subnet_tag_filters | A map of additional tags to filter subnets on. | `map(string)` | `{}` | no |
| task_definition_family | The family and revision (family:revision) or just the family if you want to use the latest revision, that you want to run in your service | `string` | n/a | yes |
| task_definition_revision | The task definition revision that you want to  create your service with. Will only be recognized on initial creation | `string` | `""` | no |
| vpc_id | An optional vpc_id to provide. This overrides data lookups and you must also provide subnet_ids | `any` | `null` | no |
| vpc_tag_key_override | The tag-key to override standard VPC lookup, defaults to var.project | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ID of the ECS service |
| cluster | The name of the cluster the ECS service is running on |
| name | The name of the ECS service |
| security_group_id | The ID of the security group attached to the ECS service |
| service_discovery_arn | The ARN of the service discovery application |
| service_discovery_id | The ID of the service discovery service |


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
| [aws_cloudwatch_log_group.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_security_group.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.ecs_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_service_discovery_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet_ids.app_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) | data source |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity_provider_strategies"></a> [capacity\_provider\_strategies](#input\_capacity\_provider\_strategies) | The capacity provider strategies to use for a service. | <pre>list(object({<br>    capacity_provider = string<br>    weight            = number<br>    base              = number<br>  }))</pre> | `[]` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | The cluster name where the service should be placed. | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The container port | `number` | `3000` | no |
| <a name="input_deployment_controller_type"></a> [deployment\_controller\_type](#input\_deployment\_controller\_type) | Type of deployment controller. Valid values: CODE\_DEPLOY, ECS | `string` | `"ECS"` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | Upper limit (% of desired\_count) of # of running tasks during a deployment | `number` | `200` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Lower limit (% of desired\_count) of # of running tasks during a deployment | `number` | `100` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The desired task count for the service | `number` | `2` | no |
| <a name="input_ecs_service_tags"></a> [ecs\_service\_tags](#input\_ecs\_service\_tags) | Optionally specify additional tags to add to the ECS Service only, typically used for scheduling resources. | `map(string)` | `null` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Whether or not to create this module | `bool` | `true` | no |
| <a name="input_enable_circuit_breaker"></a> [enable\_circuit\_breaker](#input\_enable\_circuit\_breaker) | If true, enables the ECS Circuit Breaker functionality. Has no effect if deployment\_controller\_type is CODE\_DEPLOY. | `bool` | `true` | no |
| <a name="input_enable_circuit_breaker_rollback"></a> [enable\_circuit\_breaker\_rollback](#input\_enable\_circuit\_breaker\_rollback) | If set to true, deployments that fail the circuit breaker will automatically be rolled back. See [the circuit breaker docs](https://aws.amazon.com/blogs/containers/announcing-amazon-ecs-deployment-circuit-breaker/) for more information. | `bool` | `false` | no |
| <a name="input_enable_ecs_managed_tags"></a> [enable\_ecs\_managed\_tags](#input\_enable\_ecs\_managed\_tags) | Specifies whether to enable Amazon ECS managed tags for the tasks within the service | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment to which the application belongs | `string` | n/a | yes |
| <a name="input_fargate_platform_version"></a> [fargate\_platform\_version](#input\_fargate\_platform\_version) | The platform version on which to run your service. Only applicable for launch\_type set to FARGATE. Defaults to LATEST | `string` | `"LATEST"` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200 | `number` | `0` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | The launch type on which to run your service. The valid values are EC2 and FARGATE | `string` | `"FARGATE"` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | Custom cloudwatch log group name, if desired | `string` | `""` | no |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | The time in days to keep Cloudwatch Logs. If this is set to 0 the logs will be retained indefinitely. | `string` | `"14"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of your application | `string` | n/a | yes |
| <a name="input_namespace_id"></a> [namespace\_id](#input\_namespace\_id) | The ID of the namespace to use for DNS configuration | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project to which the application belongs. | `string` | n/a | yes |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK\_DEFINITION | `string` | `""` | no |
| <a name="input_scheduling_strategy"></a> [scheduling\_strategy](#input\_scheduling\_strategy) | The scheduling strategy to use for the service. The valid values are REPLICA and DAEMON | `string` | `"REPLICA"` | no |
| <a name="input_service_discovery_dns_name"></a> [service\_discovery\_dns\_name](#input\_service\_discovery\_dns\_name) | The DNS name of the service | `string` | `""` | no |
| <a name="input_service_discovery_health_check_failure_threshold"></a> [service\_discovery\_health\_check\_failure\_threshold](#input\_service\_discovery\_health\_check\_failure\_threshold) | The number of consecutive health checks. Maximum value of 10 | `number` | `1` | no |
| <a name="input_service_discovery_routing_policy"></a> [service\_discovery\_routing\_policy](#input\_service\_discovery\_routing\_policy) | The routing policy that you want to apply to all records that Route 53 creates when you register an instance and specify the service. Valid Values: MULTIVALUE, WEIGHTED | `string` | `"MULTIVALUE"` | no |
| <a name="input_service_discovery_ttl"></a> [service\_discovery\_ttl](#input\_service\_discovery\_ttl) | The TTL for the service discovery service | `number` | `10` | no |
| <a name="input_service_discovery_type"></a> [service\_discovery\_type](#input\_service\_discovery\_type) | The Type of service discovery record to create, valid values are 'SRV' or 'A' | `string` | `"A"` | no |
| <a name="input_service_security_groups"></a> [service\_security\_groups](#input\_service\_security\_groups) | List of security groups to attach to the ECS service | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | An optional list of subnet\_ids to provide. This overrides data lookups and you must also provide vpc\_id | `set(string)` | `[]` | no |
| <a name="input_subnet_tag_filters"></a> [subnet\_tag\_filters](#input\_subnet\_tag\_filters) | A map of additional tags to filter subnets on. | `map(string)` | `{}` | no |
| <a name="input_task_definition_family"></a> [task\_definition\_family](#input\_task\_definition\_family) | The family and revision (family:revision) or just the family if you want to use the latest revision, that you want to run in your service | `string` | n/a | yes |
| <a name="input_task_definition_revision"></a> [task\_definition\_revision](#input\_task\_definition\_revision) | The task definition revision that you want to  create your service with. Will only be recognized on initial creation | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | An optional vpc\_id to provide. This overrides data lookups and you must also provide subnet\_ids | `any` | `null` | no |
| <a name="input_vpc_tag_key_override"></a> [vpc\_tag\_key\_override](#input\_vpc\_tag\_key\_override) | The tag-key to override standard VPC lookup, defaults to var.project | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ID of the ECS service |
| <a name="output_cluster"></a> [cluster](#output\_cluster) | The name of the cluster the ECS service is running on |
| <a name="output_name"></a> [name](#output\_name) | The name of the ECS service |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group attached to the ECS service |
| <a name="output_service_discovery_arn"></a> [service\_discovery\_arn](#output\_service\_discovery\_arn) | The ARN of the service discovery application |
| <a name="output_service_discovery_id"></a> [service\_discovery\_id](#output\_service\_discovery\_id) | The ID of the service discovery service |
<!-- END_TF_DOCS -->