terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.67.0"
    }
  }
}

provider "aws" {
  region = var.region
}

/*
* Requirement: already existing VPC, because AWS limit is 5 per Account
*/
module "networking" {
  source = "./modules/networking"

  aws_vpc_id    = var.aws_vpc_id
  subnet_values = var.subnet_values
}

module "alb_sg" {
  source = "./modules/security_group"

  aws_vpc_id = var.aws_vpc_id

  sg_values         = var.alb_sg_values
  sg_ingress_values = var.alb_sg_ingress_values
  sg_egress_values  = var.alb_sg_egress_values
}

module "ec2_sg" {
  source = "./modules/security_group"

  aws_vpc_id = var.aws_vpc_id

  sg_values = var.ecs_sg_values
  sg_ingress_values = [{
    ingress_description     = "temp. ssh host access"
    ingress_from_port       = 22
    ingress_to_port         = 22
    ingress_protocol        = "tcp"
    ingress_cidr_blocks     = ["0.0.0.0/0"]
    ingress_security_groups = []
    }, {
    ingress_description     = "jitsi http port"
    ingress_from_port       = 8000
    ingress_to_port         = 8000
    ingress_protocol        = "tcp"
    ingress_cidr_blocks     = []
    ingress_security_groups = [module.alb_sg.aws_security_group_id]
    }, {
    ingress_description     = "synapse http port"
    ingress_from_port       = 8008
    ingress_to_port         = 8008
    ingress_protocol        = "tcp"
    ingress_cidr_blocks     = []
    ingress_security_groups = [module.alb_sg.aws_security_group_id]
    }, {
    ingress_description     = "jvp udp port for video streaming"
    ingress_from_port       = 10000
    ingress_to_port         = 10000
    ingress_protocol        = "udp"
    ingress_cidr_blocks     = ["0.0.0.0/0"]
    ingress_security_groups = []
    }, {
    ingress_description     = "efs port"
    ingress_from_port       = 2049
    ingress_to_port         = 2049
    ingress_protocol        = "tcp"
    ingress_cidr_blocks     = []
    ingress_security_groups = [module.alb_sg.aws_security_group_id]
    }, {
    ingress_description     = "element http port"
    ingress_from_port       = 8080
    ingress_to_port         = 8080
    ingress_protocol        = "tcp"
    ingress_cidr_blocks     = []
    ingress_security_groups = [module.alb_sg.aws_security_group_id]
  }]
  sg_egress_values = var.alb_sg_egress_values
}

/*
* EFS creation working, but paths for container mount not automatically created
* need to create access points for every EFS sub-dir or manuel/lambda creates sub-dirs
*
* we will use the existing jtisi/matrix efs
*/
#module "efs" {
#  source                  = "./modules/efs"
#  efs_name                = var.efs_name
#  ecs_task_volumes_concat = concat(var.ecs_task_volumes_jitsi, var.ecs_task_volumes_matrix)
#}

// IAM assume role for ECS cluster
module "ecs_iam" {
  source = "./modules/iam"

  iam_role_name             = "ecs-agent"
  iam_instance_profile_name = "ecs-agent"
}

// Create EC2 instances
module "ecs_ec2" {
  source = "./modules/ec2"

  ecs_lc_image_id                   = "ami-0e8f6957a4eb67446"
  ecs_lc_iam_profile                = module.ecs_iam.aws_iam_instance_profile_name
  ecs_lc_sg                         = [module.ec2_sg.aws_security_group_id]
  ecs_lc_user_data                  = "#!/bin/bash\necho ECS_CLUSTER=test-cluster >> /etc/ecs/ecs.config"
  ecs_lc_instance_type              = "c5a.large"
  ecs_asg_name                      = "ecs-asg"
  ecs_asg_vpc_zone_identifier       = module.networking.aws_subnet_id
  ecs_asg_desired_capacity          = 1
  ecs_asg_min_size                  = 1
  ecs_asg_max_size                  = 1
  ecs_asg_health_check_grace_period = 300
  ecs_asg_health_check_type         = "EC2"

  ecs_ec2_depends_on = [module.ecs_iam.aws_iam_instance_profile_name]
}

module "ecs_lb" {
  source = "./modules/elb"

  lb_name                = "test-alb"
  lb_internal            = false
  lb_type                = "application"
  lb_sg                  = [module.alb_sg.aws_security_group_id]
  lb_subnet              = module.networking.aws_subnet_id
  lb_deletion_protection = false

  lb_tg_values = [{
    lb_tg_name                  = "jitsi-http-target"
    lb_tg_port                  = 8000
    lb_tg_protocol              = "HTTP"
    lb_tg_vpc                   = var.aws_vpc_id
    lb_tg_target_type           = "instance"
    lb_tg_health_check_endabled = true
    lb_tg_health_check_path     = "/"
    lb_tg_health_check_protocol = "HTTP"

    }, {
    lb_tg_name                  = "element-http-target"
    lb_tg_port                  = 8080
    lb_tg_protocol              = "HTTP"
    lb_tg_vpc                   = var.aws_vpc_id
    lb_tg_target_type           = "instance"
    lb_tg_health_check_endabled = true
    lb_tg_health_check_path     = "/"
    lb_tg_health_check_protocol = "HTTP"
    }, {
    lb_tg_name                  = "synapse-http-target"
    lb_tg_port                  = 8008
    lb_tg_protocol              = "HTTP"
    lb_tg_vpc                   = var.aws_vpc_id
    lb_tg_target_type           = "instance"
    lb_tg_health_check_endabled = true
    lb_tg_health_check_path     = "/health"
    lb_tg_health_check_protocol = "HTTP"
  }]

  lb_listener_values = [{
    lb_listener_port                = "80"
    lb_listener_protocol            = "HTTP"
    lb_listener_ssl_policy          = "" //empty for http
    lb_listener_cert_arn            = "" //empty for http
    lb_listener_default_action_type = "redirect"
    lb_listener_default_tg_name     = ""
    }, {
      lb_listener_port                = "443"
      lb_listener_protocol            = "HTTPS"
      lb_listener_ssl_policy          = "ELBSecurityPolicy-2016-08"
      lb_listener_cert_arn            = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
      lb_listener_default_action_type = "forward"
      lb_listener_default_tg_name     = "jitsi-http-target"
    }
  ]

  lb_listener_rules_values = [{
    lb_listener_rule_port                  = "80"
    lb_listener_rule_priority              = 100
    lb_listener_rule_action_type           = "forward"
    lb_listener_rule_action_tg_name        = "synapse-http-target"
    lb_listener_rule_condition_host_header = ["matrix.virtual.software.testingmachine.eu", "synapse.virtual.software.testingmachine.eu"]
    }, {
    lb_listener_rule_port                  = "80"
    lb_listener_rule_priority              = 99
    lb_listener_rule_action_type           = "forward"
    lb_listener_rule_action_tg_name        = "element-http-target"
    lb_listener_rule_condition_host_header = ["element.virtual.software.testingmachine.eu"]
  }]
}


// ECS Cluster
module "ecs_cluster" {
  source = "./modules/ecs"

  ecs_cluster_name = "test-cluster"
}

// Task definition from jitsi meet prod or staging
module "ecs_task_definitions_jitsi" {
  source = "./modules/ecs_task_definition"

  ecs_task_values  = var.ecs_task_values_jitsi
  file_system_id   = "fs-08fe793123d2b34c1" //module.efs.efs_id
  ecs_task_volumes = var.ecs_task_volumes_jitsi

  // ECS Service values
  ecs_service_name          = "test-jitsi-service"
  ecs_cluster_id            = module.ecs_cluster.ecs_cluster_id
  ecs_service_desired_count = 1

  ecs_service_lb_values = [{
    ecs_service_lb_tg_arn          = module.ecs_lb.aws_lb_target_groups.jitsi-http-target.arn
    ecs_service_lb_container_name  = "web"
    ecs_service_lb_contaiener_port = 80
  }]
}

// Task definition from matrix prod or staging
module "ecs_task_definitions_matrix" {
  source = "./modules/ecs_task_definition"

  ecs_task_values  = var.ecs_task_values_matrix
  file_system_id   = "fs-08fe793123d2b34c1" //module.efs.efs_id
  ecs_task_volumes = var.ecs_task_volumes_matrix

  // ECS Service values
  ecs_service_name          = "test-matrix-service"
  ecs_cluster_id            = module.ecs_cluster.ecs_cluster_id
  ecs_service_desired_count = 1

  ecs_service_lb_values = [{
    ecs_service_lb_tg_arn          = module.ecs_lb.aws_lb_target_groups.element-http-target.arn
    ecs_service_lb_container_name  = "element"
    ecs_service_lb_contaiener_port = 80
    }, {
    ecs_service_lb_tg_arn          = module.ecs_lb.aws_lb_target_groups.synapse-http-target.arn
    ecs_service_lb_container_name  = "synapse"
    ecs_service_lb_contaiener_port = 8008
  }]
}
