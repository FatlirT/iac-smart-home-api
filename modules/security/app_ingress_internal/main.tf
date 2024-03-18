resource "aws_security_group" "app_ingress_internal" {
  vpc_id      = var.vpc_id
  name = "app_ingress_internal"
  tags = {
    App = "ce-smart-home"
  }
}


resource "aws_security_group_rule" "app_ingress_internal_rule" {
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  security_group_id = aws_security_group.app_ingress_internal.id
  source_security_group_id = var.internal_source
}
