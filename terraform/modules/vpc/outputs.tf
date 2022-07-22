// VPC info
output "vpc_id" {
  value = aws_vpc.project.id
}

output "vpc_cidr" {
  value = aws_vpc.project.cidr_block
}

// DMZ subnets info
output "dmz_subnet_cidrs" {
  value = aws_subnet.dmz.*.cidr_block
}

output "dmz_subnet_ids" {
  value = aws_subnet.dmz.*.id
}

// App subnets info
output "app_subnet_cidrs" {
  value = aws_subnet.app.*.cidr_block
}

output "app_subnet_ids" {
  value = aws_subnet.app.*.id
}

// DB/private subnets info
output "db_subnet_cidrs" {
  value = aws_subnet.db.*.cidr_block
}

output "db_subnet_ids" {
  value = aws_subnet.db.*.id
}

output "nat_gateway_public_ips" {
  value = aws_nat_gateway.ngw.*.public_ip
}

output "dmz_route_table_id" {
  value = aws_route_table.pub.id
}

output "priv_route_table_ids" {
  value = aws_route_table.priv.*.id
}
