data "aws_availability_zones" "available" {}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr    = "10.0.0.0/24"
  project     = "skillboard"
  environment = "development"
  azs         = data.aws_availability_zones.available.names
}


# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id       = module.vpc.vpc_id
#   service_name = "com.amazonaws.us-east-1.ecr.api"
# }

# resource "aws_vpc_endpoint_route_table_association" "ecr_api_private" {
#   count           = length(module.vpc.priv_route_table_ids)
#   route_table_id  = module.vpc.priv_route_table_ids[count.index]
#   vpc_endpoint_id = aws_vpc_endpoint.ecr_api.id

#   depends_on = [time_sleep.wait]
# }

# resource "aws_vpc_endpoint_route_table_association" "ecr_api_public" {
#   route_table_id  = module.vpc.dmz_route_table_id
#   vpc_endpoint_id = aws_vpc_endpoint.ecr_api.id

#   depends_on = [time_sleep.wait]
# }

# resource "time_sleep" "wait" {
#   depends_on      = [module.vpc]
#   create_duration = "10s"
# }
