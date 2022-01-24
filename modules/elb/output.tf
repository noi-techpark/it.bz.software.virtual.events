output "aws_lg_arn" {
  value = aws_lb.elb.arn
}

output "aws_lb_target_groups" {
  #value = tomap({
  #  for k, tg in aws_lb_target_group.test : k => tg.name
  #})
  value = {
    for k, tg in aws_lb_target_group.tgs : k => ({ "name" = tg.name, "arn" = tg.arn })
  }
}