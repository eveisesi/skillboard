resource "aws_service_discovery_private_dns_namespace" "skillboard" {
  name        = "skillboard.local"
  description = "Contains all of the internal skillboard resources"
  vpc         = module.vpc.vpc_id
}
