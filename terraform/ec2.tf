resource "aws_security_group" "ecs" {
  name        = "skillboard-ecs"
  description = "Security Group used by Skillboard ECS"
  vpc_id      = aws_vpc.skillboard.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs.id

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_ingress" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs.id
  self              = true
}
