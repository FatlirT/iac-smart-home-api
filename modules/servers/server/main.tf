resource "aws_instance" "server" {
  
  ami = "ami-0d18e50ca22537278"
  instance_type          = var.type
  key_name               = var.inbound_ssh_permissions != null ? var.inbound_ssh_permissions.key_name : null
  monitoring             = true  
  vpc_security_group_ids = concat(var.security_group_ids, (var.inbound_ssh_permissions != null ? [var.inbound_ssh_permissions.sg_id] : []))
  subnet_id              = var.subnet_id
   tags = {
    Name = var.name
    App = "ce-smart-home"
  }
  iam_instance_profile = var.ip_name
  user_data = var.app_source != null ? base64encode(<<EOT
${file("modules/servers/server/ud-incomplete")}
    git clone git@github.com:FatlirT/${var.app_source}.git
    cd ${var.app_source}

    echo "ACCESS_KEY=$(aws secretsmanager get-secret-value --secret-id ce-smart-home-dynamo-ak --query SecretString --output text)" >> .env.local
    echo "SECRET_ACCESS_KEY=$(aws secretsmanager get-secret-value --secret-id ce-smart-home-dynamo-sak --query SecretString --output text)" >> .env.local

    npm install 

    pm2 start npm -- run start 
  "
  EOT
  ) : null

}