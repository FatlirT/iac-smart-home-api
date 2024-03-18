resource "aws_security_group" "ssh_egress" {
  vpc_id      = var.vpc_id
  name = "ssh_egress"
  tags = {
    App = "ce-smart-home"
  }
}

resource "aws_security_group_rule" "ssh_egress_rule" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.ssh_egress.id
}
