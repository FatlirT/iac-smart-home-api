resource "aws_security_group" "app_ingress" {
  vpc_id      = var.vpc_id
  name = "app_ingress"
  tags = {
    App = "ce-smart-home"
  }
}

resource "aws_security_group_rule" "app_ingress_rule" {
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.app_ingress.id
}