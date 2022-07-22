variable "vpc_cidr" {
  description = "CIDR block for this VPC"
  type        = string
}

variable "azs" {
  description = "List of Availability zones for this VPC"
  type        = list(string)
}

variable "tags" {
  type        = map(string)
  description = "Optionally specify additional tags to add to the VPC. Please reference the [AWS Implementation Guide](https://security.rvdocs.io/guides/aws-implementation.html#required-tags) for more details on what tags are required"
  default     = {}
}

variable "app_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "Optional map of extra tags for app subnets."
}

variable "dmz_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "Optional map of extra tags for dmz subnets."
}

variable "db_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "Optional map of extra for db tags subnets."
}

variable "project" {
  description = "Project to which the VPC belongs."
  type        = string
}

variable "main_acct_num" {
  description = "DEPRECATED: has no effect"
  type        = string
  default     = null
}

variable "environment" {
  description = "The environment to which this VPC belongs"
  type        = string
}

variable "propagating_vgws" {
  type    = list(string)
  default = []
}

variable "propagating_vgws_public" {
  type    = list(string)
  default = []
}

variable "propagating_vgws_private" {
  type    = list(string)
  default = []
}

variable "create_single_nat_gateway" {
  description = "Where or not to only create a Single Nat Gateway."
  type        = bool
  default     = false
}

variable "enable_basic_flow_logs" {
  description = "If true, flow logs to CloudWatch will be enabled for the created VPC"
  type        = bool
  default     = true
}

variable "log_retention" {
  type        = number
  description = "The time in days to retain flow logs. If this is set to 0 the logs will be retained indefinitely."
  default     = 30
}

variable "flow_logs" {
  description = "Additional, flow logs configuration. Supports more customization than the default flow logs configuration"
  type        = list(map(any))
  default     = []
}
