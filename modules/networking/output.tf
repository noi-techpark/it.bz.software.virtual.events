output "aws_security_group_id" {
  value = aws_security_group.ecs_sg.id
}

output "aws_subnet_id" {
  value = aws_subnet.subnet.id
}