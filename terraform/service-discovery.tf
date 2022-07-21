resource "aws_service_discovery_private_dns_namespace" "skillboard" {
  name        = "skillboard.local"
  description = "Contains all of the internal skillboard resources"
  vpc         = aws_vpc.skillboard.id
}

resource "aws_service_discovery_service" "skillboard_nuxt" {
  name = "skillboard-nuxt"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.skillboard.id

    dns_records {
      ttl  = 60
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }
}
