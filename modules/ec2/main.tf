resource "aws_launch_configuration" "ecs_launch_config" {
  image_id                    = var.ecs_lc_image_id
  iam_instance_profile        = var.ecs_lc_iam_profile
  security_groups             = var.ecs_lc_sg
  associate_public_ip_address = true
  user_data                   = var.ecs_lc_user_data
  instance_type               = var.ecs_lc_instance_type

  key_name = "karls-key-pair"
  depends_on = [
    var.ecs_ec2_depends_on
  ]
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                 = var.ecs_asg_name
  vpc_zone_identifier  = var.ecs_asg_vpc_zone_identifier
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = var.ecs_asg_desired_capacity
  min_size                  = var.ecs_asg_min_size
  max_size                  = var.ecs_asg_max_size
  health_check_grace_period = var.ecs_asg_health_check_grace_period
  health_check_type         = var.ecs_asg_health_check_type
}