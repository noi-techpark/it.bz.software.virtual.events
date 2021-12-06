resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = var.ecs_lc_image_id    //"ami-0e8f6957a4eb67446"
  iam_instance_profile = var.ecs_lc_iam_profile //aws_iam_instance_profile.ecs_agent.name
  security_groups      = var.ecs_lc_sg          //[aws_security_group.ecs_sg.id]
  associate_public_ip_address = true
  // change my-custer
  user_data     = var.ecs_lc_user_data     //"#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
  instance_type = var.ecs_lc_instance_type //"t3.micro"

  key_name = "karls-key-pair"
  depends_on = [
    var.ecs_ec2_depends_on
  ]
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                 = var.ecs_asg_name                 //"asg"
  vpc_zone_identifier  = var.ecs_asg_vpc_zone_identifier  //[aws_subnet.pub_subnet.id]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = var.ecs_asg_desired_capacity          //1
  min_size                  = var.ecs_asg_min_size                  //1
  max_size                  = var.ecs_asg_max_size                  //1
  health_check_grace_period = var.ecs_asg_health_check_grace_period //300
  health_check_type         = var.ecs_asg_health_check_type         //"EC2"
}