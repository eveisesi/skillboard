data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  name = "${var.project}-${var.environment}"

  dmz_subnet_tags = {
    dmz = true
    app = false
    db  = false
  }

  app_subnet_tags = {
    dmz = false
    app = true
    db  = false
  }

  db_subnet_tags = {
    dmz = false
    app = false
    db  = true
  }
}


/**
 * VPC
 */
resource "aws_vpc" "project" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name          = local.name
    (var.project) = true
  })
}

/**
 * Elastic IP/EIP
 */
resource "aws_eip" "ngw" {
  vpc   = true
  count = 1
}

/**
 * Gateways
 */
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project.id

  tags = merge(var.tags, {
    Name = "${local.name}-igw"
  })
}

resource "aws_nat_gateway" "ngw" {
  count         = 1
  allocation_id = element(aws_eip.ngw.*.id, count.index)
  subnet_id     = element(aws_subnet.dmz.*.id, count.index)
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(var.tags, {
    Name = format("%s-natgw-%02d", local.name, count.index)
  })
}

/**
 * Route tables
 */
resource "aws_route_table" "pub" {
  vpc_id           = aws_vpc.project.id
  propagating_vgws = concat(var.propagating_vgws, var.propagating_vgws_public)

  tags = merge(var.tags, {
    Name = "${local.name}-pub"
  })
}

resource "aws_route" "pub_default_gateway" {
  route_table_id         = aws_route_table.pub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "priv" {
  count = 1

  vpc_id           = aws_vpc.project.id
  propagating_vgws = concat(var.propagating_vgws, var.propagating_vgws_private)

  tags = merge(var.tags, {
    Name = format("%s-priv-%02d", local.name, count.index)
  })
}

resource "aws_route" "priv_default_gateway" {
  count                  = 1
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = element(aws_route_table.priv.*.id, count.index)
  nat_gateway_id         = var.create_single_nat_gateway ? element(aws_nat_gateway.ngw.*.id, 0) : element(aws_nat_gateway.ngw.*.id, count.index)
}

/**
 * DMZ
 */
resource "aws_subnet" "dmz" {
  count = 1

  vpc_id                  = aws_vpc.project.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.tags, local.dmz_subnet_tags, {
    Name = format("%s-dmz%02d", local.name, count.index)
    az   = element(var.azs, count.index)
  })
}

resource "aws_route_table_association" "pub_dmz" {
  count = 1

  subnet_id      = element(aws_subnet.dmz.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

/**
 * Data/DB/Redis
 */
resource "aws_subnet" "db" {
  count = 1

  vpc_id                  = aws_vpc.project.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 4 + count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(var.tags, local.db_subnet_tags, {
    Name = format("%s-db%02d", local.name, count.index)
    az   = element(var.azs, count.index)
  })
}

resource "aws_route_table_association" "priv_db" {
  count = 1

  subnet_id      = element(aws_subnet.db.*.id, count.index)
  route_table_id = element(aws_route_table.priv.*.id, count.index)
}

/**
 * App
 */
resource "aws_subnet" "app" {
  count = 1

  vpc_id                  = aws_vpc.project.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 4 + count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(var.tags, local.app_subnet_tags, {
    Name = format("%s-app%02d", local.name, count.index)
    az   = element(var.azs, count.index)
  })
}

resource "aws_route_table_association" "priv_app" {
  count = 1

  subnet_id      = element(aws_subnet.app.*.id, count.index)
  route_table_id = element(aws_route_table.priv.*.id, count.index)
}

# /**
#  * Flow Logs
#  */
# resource "aws_flow_log" "flow_log" {
#   count = var.enable_basic_flow_logs ? 1 : 0

#   log_destination = aws_cloudwatch_log_group.log_group[0].arn
#   iam_role_arn    = var.flow_log_role_arn
#   vpc_id          = aws_vpc.project.id
#   traffic_type    = "ALL"

#   tags = var.tags
# }

# resource "aws_cloudwatch_log_group" "log_group" {
#   count = var.enable_basic_flow_logs ? 1 : 0

#   name              = "${var.project}-log-group-${var.environment}"
#   retention_in_days = var.log_retention
# }

# locals {
#   flow_logs = [
#     for config in var.flow_logs : {
#       destination              = tostring(config.destination_arn)
#       traffic_type             = try(tostring(config.traffic_type), "ALL")
#       role                     = try(tostring(config.role_arn), null)
#       type                     = try(tostring(config.type), "cloud-watch-logs")
#       log_format               = try(tostring(config.log_format), null)
#       max_aggregation_interval = try(tonumber(config.max_aggregation_interval), null)
#     }
#   ]
# }

# resource "aws_flow_log" "flow_logs" {
#   count = length(local.flow_logs)

#   traffic_type             = local.flow_logs[count.index].traffic_type
#   iam_role_arn             = local.flow_logs[count.index].role
#   log_destination_type     = local.flow_logs[count.index].type
#   log_destination          = local.flow_logs[count.index].destination
#   vpc_id                   = aws_vpc.project.id
#   log_format               = local.flow_logs[count.index].log_format
#   max_aggregation_interval = local.flow_logs[count.index].max_aggregation_interval

#   tags = var.tags
# }
