output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id if subnet.vpc_id == aws_vpc.vpc.id]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id if subnet.vpc_id == aws_vpc.vpc.id]
}

output "default_security_group_id" {
  value = aws_vpc.vpc.default_security_group_id
}