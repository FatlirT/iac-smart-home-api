resource "aws_security_group" "web_egress" {
  vpc_id      = var.vpc_id
  name = "web_egress"
  tags = {
    App = "ce-smart-home"
  }
}

resource "aws_security_group_rule" "http_egress_rule" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.web_egress.id
}

resource "aws_security_group_rule" "https_egress_rule" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.web_egress.id
}
