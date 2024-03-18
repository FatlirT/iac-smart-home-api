data "http" "myipaddr" {
   url = "http://icanhazip.com"
}


resource "aws_security_group" "ssh_myip_to_bastion" {
  vpc_id      = var.vpc_id
  name = "ssh_myip_to_bastion"
  tags = {
    App = "ce-smart-home"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_myip_to_bastion_rule" {
  security_group_id = aws_security_group.ssh_myip_to_bastion.id

  cidr_ipv4   = "${chomp(data.http.myipaddr.response_body)}/32"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}


resource "aws_security_group" "ssh_bastion_to_app" {
  vpc_id      = var.vpc_id
  name = "ssh_bastion_to_app"
  tags = {
    App = "ce-smart-home"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_bastion_to_app_rule" {
  security_group_id = aws_security_group.ssh_bastion_to_app.id

  referenced_security_group_id = aws_security_group.ssh_myip_to_bastion.id
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

