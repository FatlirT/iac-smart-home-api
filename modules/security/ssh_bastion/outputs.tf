output "ssh_bastion_to_app_sg_id" {
  value = aws_security_group.ssh_bastion_to_app.id
}

output "ssh_myip_to_bastion_sg_id" {
  value = aws_security_group.ssh_myip_to_bastion.id
}