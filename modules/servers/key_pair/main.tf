resource "aws_key_pair" "ssh_kp" {
  public_key = file("credentials/${var.name}.pub")
  key_name = var.name
}

