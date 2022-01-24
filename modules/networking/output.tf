output "aws_subnet_id" {
  value = toset([
    for subnet in aws_subnet.subnet : subnet.id
  ])
}
