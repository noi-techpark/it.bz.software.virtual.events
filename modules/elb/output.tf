output "aws_lb_target_group_arns" {
  value = toset([
    for tg in aws_lb_target_group.test : tg.arn
  ])
}