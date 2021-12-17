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
  default_tags {
    tags = var.default_tags
  }
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

  sg_values = var.alb_sg_values
  sg_ingress_values = [{
    ingress_description     = "standard https port"
    ingress_from_port       = 443
    ingress_to_port         = 443
    ingress_protocol        = "tcp"
    ingress_cidr_blocks     = ["0.0.0.0/0"]
    ingress_security_groups = []
    }, {
    ingress_description     = "standard http port"
    ingress_from_port       = 80
    ingress_to_port         = 80
    ingress_protocol        = "tcp"
    ingress_cidr_blocks     = ["0.0.0.0/0"]
    ingress_security_groups = []
    }, {
    ingress_description     = "synapse federation port"
    ingress_from_port       = 8448
    ingress_to_port         = 8448
    ingress_protocol        = "tcp"
    ingress_cidr_blocks     = ["0.0.0.0/0"]
    ingress_security_groups = []
    }, {
    ingress_description     = "jvb udp test"
    ingress_from_port       = 10000
    ingress_to_port         = 10000
    ingress_protocol        = "udp"
    ingress_cidr_blocks     = ["0.0.0.0/0"]
    ingress_security_groups = []
  }]
  sg_egress_values = [{
    egress_from_port   = 0
    egress_to_port     = 0
    egress_protocol    = "-1"
    egress_destination = ["0.0.0.0/0"]
  }]
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
  sg_egress_values = [{
    egress_from_port   = 0
    egress_to_port     = 0
    egress_protocol    = "-1"
    egress_destination = ["0.0.0.0/0"]
  }]
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

# IAM assume role for ECS cluster
module "ecs_iam" {
  source = "./modules/iam"

  iam_role_name             = var.ecs_iam_role_name
  iam_instance_profile_name = var.ecs_iam_instance_profile_name
}

# Create EC2 instances
module "ecs_ec2" {
  source = "./modules/ec2"

  ecs_lc_image_id                   = var.ecs_lc_image_id
  ecs_lc_iam_profile                = module.ecs_iam.aws_iam_instance_profile_name
  ecs_lc_sg                         = [module.ec2_sg.aws_security_group_id]
  ecs_lc_user_data                  = var.ecs_lc_user_data
  ecs_lc_instance_type              = var.ecs_lc_instance_type
  ecs_asg_name                      = var.ecs_asg_name
  ecs_asg_vpc_zone_identifier       = module.networking.aws_subnet_id
  ecs_asg_desired_capacity          = var.ecs_asg_desired_capacity
  ecs_asg_min_size                  = var.ecs_asg_min_size
  ecs_asg_max_size                  = var.ecs_asg_max_size
  ecs_asg_health_check_grace_period = var.ecs_asg_health_check_grace_period
  ecs_asg_health_check_type         = var.ecs_asg_health_check_type

  ecs_ec2_depends_on = [module.ecs_iam.aws_iam_instance_profile_name]
}

# Create one LB with multiple target groups, listener and LB rules
module "ecs_lb" {
  source = "./modules/elb"

  lb_name                = var.lb_name
  lb_internal            = var.lb_internal
  lb_type                = var.lb_type
  lb_sg                  = [module.alb_sg.aws_security_group_id]
  lb_subnet              = module.networking.aws_subnet_id
  lb_deletion_protection = var.lb_deletion_protection

  lb_tg_values = [{
    lb_tg_name                  = var.lb_tg_name_jitsi
    lb_tg_port                  = 8000
    lb_tg_protocol              = "HTTP"
    lb_tg_vpc                   = var.aws_vpc_id
    lb_tg_target_type           = "instance"
    lb_tg_health_check_endabled = true
    lb_tg_health_check_path     = "/"
    lb_tg_health_check_protocol = "HTTP"

    }, {
    lb_tg_name                  = var.lb_tg_name_element
    lb_tg_port                  = 8080
    lb_tg_protocol              = "HTTP"
    lb_tg_vpc                   = var.aws_vpc_id
    lb_tg_target_type           = "instance"
    lb_tg_health_check_endabled = true
    lb_tg_health_check_path     = "/"
    lb_tg_health_check_protocol = "HTTP"
    }, {
    lb_tg_name                  = var.lb_tg_name_synapse
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
    lb_listener_ssl_policy          = var.lb_listener_ssl_policy
    lb_listener_cert_arn            = var.lb_listener_cert_arn
    lb_listener_default_action_type = "forward"
    lb_listener_default_tg_name     = var.lb_tg_name_jitsi
    }
  ]

  lb_listener_rules_values = [{
    lb_listener_rule_port                  = "80"
    lb_listener_rule_priority              = 100
    lb_listener_rule_action_type           = "forward"
    lb_listener_rule_action_tg_name        = var.lb_tg_name_synapse
    lb_listener_rule_condition_host_header = var.lb_listener_rule_condition_host_header_matrix-synapse
    }, {
    lb_listener_rule_port                  = "80"
    lb_listener_rule_priority              = 99
    lb_listener_rule_action_type           = "forward"
    lb_listener_rule_action_tg_name        = var.lb_tg_name_element
    lb_listener_rule_condition_host_header = var.lb_listener_rule_condition_host_header_element
  }]
}


# ECS Cluster
module "ecs_cluster" {
  source = "./modules/ecs"

  ecs_cluster_name = var.ecs_cluster_name
}

# Task definition from jitsi meet prod or staging
module "ecs_task_definitions_jitsi" {
  source = "./modules/ecs_task_definition"

  ecs_task_values  = var.ecs_task_values_jitsi
  file_system_id   = var.efs_id
  ecs_task_volumes = var.ecs_task_volumes_jitsi

  # ECS Service values
  ecs_service_name          = var.ecs_service_name_jitsi
  ecs_cluster_id            = module.ecs_cluster.ecs_cluster_id
  ecs_service_desired_count = 1

  ecs_service_lb_values = [{
    ecs_service_lb_tg_arn          = module.ecs_lb.aws_lb_target_groups[var.lb_tg_name_jitsi].arn
    ecs_service_lb_container_name  = "web"
    ecs_service_lb_contaiener_port = 80
  }]
}

# Task definition from matrix prod or staging
module "ecs_task_definitions_matrix" {
  source = "./modules/ecs_task_definition"

  ecs_task_values  = var.ecs_task_values_matrix
  file_system_id   = var.efs_id
  ecs_task_volumes = var.ecs_task_volumes_matrix

  # ECS Service values
  ecs_service_name          = var.ecs_service_name_matrix
  ecs_cluster_id            = module.ecs_cluster.ecs_cluster_id
  ecs_service_desired_count = 1

  ecs_service_lb_values = [{
    ecs_service_lb_tg_arn          = module.ecs_lb.aws_lb_target_groups[var.lb_tg_name_element].arn
    ecs_service_lb_container_name  = "element"
    ecs_service_lb_contaiener_port = 80
    }, {
    ecs_service_lb_tg_arn          = module.ecs_lb.aws_lb_target_groups[var.lb_tg_name_synapse].arn
    ecs_service_lb_container_name  = "synapse"
    ecs_service_lb_contaiener_port = 8008
  }]
}
