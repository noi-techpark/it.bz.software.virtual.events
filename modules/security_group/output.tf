output "aws_security_group_id" {
  value = aws_security_group.sg.id
  #value = toset([
  #  for sg in aws_security_group.ecs_sg : sg.id
  #])
}
