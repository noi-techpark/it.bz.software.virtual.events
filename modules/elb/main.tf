// Create Application LB
resource "aws_lb" "elb" {
  name               = var.lb_name
  internal           = var.lb_internal //false
  load_balancer_type = var.lb_type     //"application"
  security_groups    = var.lb_sg       //[aws_security_group.lb_sg.id]
  subnets            = var.lb_subnet   //aws_subnet.public.*.id

  enable_deletion_protection = var.lb_deletion_protection //true

  #access_logs {
  #  bucket  = aws_s3_bucket.lb_logs.bucket
  #  prefix  = "test-lb"
  #  enabled = true
  #}

  tags = {
    Environment = "production"
  }
}

// Create Target groups
resource "aws_lb_target_group" "tgs" {
  for_each    = { for lb_tg in var.lb_tg_values : lb_tg.lb_tg_name => lb_tg }
  name        = each.value.lb_tg_name
  port        = each.value.lb_tg_port
  protocol    = each.value.lb_tg_protocol
  vpc_id      = each.value.lb_tg_vpc
  target_type = each.value.lb_tg_target_type
  health_check {
    enabled  = each.value.lb_tg_health_check_endabled
    path     = each.value.lb_tg_health_check_path
    protocol = each.value.lb_tg_health_check_protocol
  }
}

// Spcifiy the action on incoming traffic -> forward to target groups
resource "aws_lb_listener" "front_end" {
  for_each          = { for listener in var.lb_listener_values : listener.lb_listener_port => listener }
  load_balancer_arn = aws_lb.elb.arn
  port              = each.value.lb_listener_port
  protocol          = each.value.lb_listener_protocol
  ssl_policy        = each.value.lb_listener_protocol == "HTTPS" ? each.value.lb_listener_ssl_policy : null
  certificate_arn   = each.value.lb_listener_protocol == "HTTPS" ? each.value.lb_listener_cert_arn : null

  default_action {
    type             = each.value.lb_listener_default_action_type
    target_group_arn = each.value.lb_listener_default_action_type == "forward" ? aws_lb_target_group.tgs[each.value.lb_listener_default_tg_name].arn : null
    # if action is set to redirect e.g. pot 80, set default https redirect
    dynamic "redirect" {
      for_each = each.value.lb_listener_default_action_type == "redirect" ? ["create only this one redirect action"] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

/*
* port 80 redirect - rule: https://#{host}:443/#{path}?#{query} - status code: 301
*
* listener on 8448 (matrix federation) - rule: forward -> 8008 -> matrix-cluster-target-staging
*/

resource "aws_lb_listener_rule" "forwarding_rules" {
  for_each     = { for rule in var.lb_listener_rules_values : rule.lb_listener_rule_action_tg_name => rule }
  listener_arn = aws_lb_listener.front_end[each.value.lb_listener_rule_port].arn
  priority     = each.value.lb_listener_rule_priority

  action {
    type             = each.value.lb_listener_rule_action_type
    target_group_arn = aws_lb_target_group.tgs[each.value.lb_listener_rule_action_tg_name].arn
  }

  condition {
    host_header {
      values = each.value.lb_listener_rule_condition_host_header
    }
  }
}
