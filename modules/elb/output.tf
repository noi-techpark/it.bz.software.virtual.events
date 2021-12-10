output "aws_lg_arn" {
  value = aws_lb.test.arn
}

output "aws_lb_target_groups" {
  #value = tomap({
  #  for k, tg in aws_lb_target_group.test : k => tg.name
  #})
  value = {
    for k, tg in aws_lb_target_group.test : k => ({ "name" = tg.name, "arn" = tg.arn })
  }
}