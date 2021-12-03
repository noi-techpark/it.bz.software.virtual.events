output "aws_subnet_id" {
  value = toset([
    for subnet in aws_subnet.subnet : subnet.id
  ])
}

output "aws_security_group_id" {
  value = aws_security_group.ecs_sg.id
  #value = toset([
  #  for sg in aws_security_group.ecs_sg : sg.id
  #])
}
