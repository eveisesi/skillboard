# VPC Module

Creates a proper 3-tier VPC. It will cover 3 AZs by default and will create the following in each AZ:

- A public subnet for a DMZ
- A private subnet for our databases and other data endpoints (i.e. S3 VPC endpoints)
- A private subnet that is 2x as large as the DMZ/DB subnets for use with application servers/lambda functions

## Usage

### Basic Usage

```hcl
module "vpc" {
  source  = "app.terraform.io/RVStandard/vpc_main/aws"
  version = "~> 3.0"

  project       = var.project
  environment   = var.environment

  vpc_cidr = var.vpc_cidr
  az_count = var.az_count
  azs      = data.aws_availability_zones.available.names

  flow_log_role_arn = module.iam.flow_log_role_arn

  tags = {
    Project     = var.project
    Environment = var.environment
    Provisioner = "terraform"
    Owner       = "platform-tools@redventures.com"
  }
}
```

### Custom Flow Logs

```hcl
module "vpc" {
  source  = "app.terraform.io/RVStandard/vpc_main/aws"
  version = "~> 3.0"

  project       = var.project
  environment   = var.environment

  vpc_cidr = var.vpc_cidr
  az_count = var.az_count
  azs      = data.aws_availability_zones.available.names

  enable_basic_flow_logs = false

  flow_logs = [
    {
      destination_arn = module.my_flow_logs_bucket.arn
      traffic_type    = "ACCEPT"
      role_arn        = aws_iam_role.my_flow_log_role.arn
      type            = "s3"
    }
  ]
}
```

You can use the `create_single_nat_gateway` flag in nonproduction environments. This flag will create a single NAT Gateway and updates all private route tables to point to this single NAT vs the NAT per AZ.

As noted, you'll typically want to use this option in non-production environments, where running multiple NAT Gateways may inflate your AWS bill. In production environments, you'll often want to set this option to `false` (which is the default), because running multiple NAT Gateways in production typically _decreases_ overall costs.

The primary reason you don't want to use this in production is because if the AZ where the single NAT gateway lives goes down, you won't be able to communicate with the internet, even if your app is spread across 3 or 4 different AZs.

## Terraform Version Compatibility

| Terraform Version | Module Version |
| :---------------: | :------------: |
|     <= v0.11      |      1.x       |
|     >= v0.12      |      3.x       |

## Contributing

Please read [this contributing doc](https://github.com/RedVentures/terraform-abstraction/blob/main/CONTRIBUTING.md) for details around contributing to the project.

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
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eip.ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_flow_log.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.priv_default_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.pub_default_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.priv](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.pub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.priv_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.priv_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.pub_dmz](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.dmz](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_subnet_tags"></a> [app\_subnet\_tags](#input\_app\_subnet\_tags) | Optional map of extra tags for app subnets. | `map(string)` | `{}` | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | The number of AZs to launch this VPC in | `number` | n/a | yes |
| <a name="input_azs"></a> [azs](#input\_azs) | List of Availability zones for this VPC | `list(string)` | n/a | yes |
| <a name="input_create_single_nat_gateway"></a> [create\_single\_nat\_gateway](#input\_create\_single\_nat\_gateway) | Where or not to only create a Single Nat Gateway. | `bool` | `false` | no |
| <a name="input_db_subnet_tags"></a> [db\_subnet\_tags](#input\_db\_subnet\_tags) | Optional map of extra for db tags subnets. | `map(string)` | `{}` | no |
| <a name="input_dmz_subnet_tags"></a> [dmz\_subnet\_tags](#input\_dmz\_subnet\_tags) | Optional map of extra tags for dmz subnets. | `map(string)` | `{}` | no |
| <a name="input_enable_basic_flow_logs"></a> [enable\_basic\_flow\_logs](#input\_enable\_basic\_flow\_logs) | If true, flow logs to CloudWatch will be enabled for the created VPC | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment to which this VPC belongs | `string` | n/a | yes |
| <a name="input_flow_log_role_arn"></a> [flow\_log\_role\_arn](#input\_flow\_log\_role\_arn) | ARN for the role to be used for flow logs. | `string` | `null` | no |
| <a name="input_flow_logs"></a> [flow\_logs](#input\_flow\_logs) | Additional, flow logs configuration. Supports more customization than the default flow logs configuration | `list(map(any))` | `[]` | no |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | The time in days to retain flow logs. If this is set to 0 the logs will be retained indefinitely. | `number` | `30` | no |
| <a name="input_main_acct_num"></a> [main\_acct\_num](#input\_main\_acct\_num) | DEPRECATED: has no effect | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | Project to which the VPC belongs. | `string` | n/a | yes |
| <a name="input_propagating_vgws"></a> [propagating\_vgws](#input\_propagating\_vgws) | n/a | `list(string)` | `[]` | no |
| <a name="input_propagating_vgws_private"></a> [propagating\_vgws\_private](#input\_propagating\_vgws\_private) | n/a | `list(string)` | `[]` | no |
| <a name="input_propagating_vgws_public"></a> [propagating\_vgws\_public](#input\_propagating\_vgws\_public) | n/a | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optionally specify additional tags to add to the VPC. Please reference the [AWS Implementation Guide](https://security.rvdocs.io/guides/aws-implementation.html#required-tags) for more details on what tags are required | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for this VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_subnet_cidrs"></a> [app\_subnet\_cidrs](#output\_app\_subnet\_cidrs) | App subnets info |
| <a name="output_app_subnet_ids"></a> [app\_subnet\_ids](#output\_app\_subnet\_ids) | n/a |
| <a name="output_db_subnet_cidrs"></a> [db\_subnet\_cidrs](#output\_db\_subnet\_cidrs) | DB/private subnets info |
| <a name="output_db_subnet_ids"></a> [db\_subnet\_ids](#output\_db\_subnet\_ids) | n/a |
| <a name="output_dmz_route_table_id"></a> [dmz\_route\_table\_id](#output\_dmz\_route\_table\_id) | n/a |
| <a name="output_dmz_subnet_cidrs"></a> [dmz\_subnet\_cidrs](#output\_dmz\_subnet\_cidrs) | DMZ subnets info |
| <a name="output_dmz_subnet_ids"></a> [dmz\_subnet\_ids](#output\_dmz\_subnet\_ids) | n/a |
| <a name="output_nat_gateway_public_ips"></a> [nat\_gateway\_public\_ips](#output\_nat\_gateway\_public\_ips) | n/a |
| <a name="output_priv_route_table_ids"></a> [priv\_route\_table\_ids](#output\_priv\_route\_table\_ids) | n/a |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC info |
<!-- END_TF_DOCS -->
