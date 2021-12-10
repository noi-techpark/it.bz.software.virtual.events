terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.67.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.region
  # ACCESS KEY
  # SECRECT ACCESS KEY
}

/*
* Requirement: already existing VPC, because AWS limit is 5 per Account
*/
module "networking" {
  source = "./modules/networking"

  aws_vpc_id    = var.aws_vpc_id
  subnet_values    = var.subnet_values

  ecs_sg_values = var.ecs_sg_values
  ecs_sg_ingress_values = var.ecs_sg_ingress_values
  ecs_sg_egress_values = var.ecs_sg_egress_values
}

/*
* EFS creation working, but paths for container mount not automatically created
* need to create access points for every EFS sub-dir or manuel/lambda creates sub-dirs
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

  ecs_lc_image_id = "ami-0e8f6957a4eb67446"
  ecs_lc_iam_profile = module.ecs_iam.aws_iam_instance_profile_name
  ecs_lc_sg = [module.networking.aws_security_group_id]
  ecs_lc_user_data = "#!/bin/bash\necho ECS_CLUSTER=test-cluster >> /etc/ecs/ecs.config"
  ecs_lc_instance_type = "c5a.large"
  ecs_asg_name = "ecs-asg"
  ecs_asg_vpc_zone_identifier = module.networking.aws_subnet_id
  ecs_asg_desired_capacity = 1
  ecs_asg_min_size = 1
  ecs_asg_max_size = 1
  ecs_asg_health_check_grace_period = 300
  ecs_asg_health_check_type = "EC2"

  ecs_ec2_depends_on = [module.ecs_iam.aws_iam_instance_profile_name]
}

module "ecs_lb" {
  source = "./modules/elb"

  lb_name = "test-alb"
  lb_internal = false
  lb_type = "application"
  lb_sg = [module.networking.aws_security_group_id]
  lb_subnet = module.networking.aws_subnet_id
  lb_deletion_protection = false

  lb_tg_values = [{
    lb_tg_name = "jitsi-http-target"
    lb_tg_port = 8000
    lb_tg_protocol = "HTTP"
    lb_tg_vpc = var.aws_vpc_id
    lb_tg_target_type = "instance"
    lb_tg_health_check_endabled = true
    lb_tg_health_check_path = "/"
    lb_tg_health_check_protocol = "HTTP"

  }, {
    lb_tg_name = "matrix-http-target"
    lb_tg_port = 8080
    lb_tg_protocol = "HTTP"
    lb_tg_vpc = var.aws_vpc_id
    lb_tg_target_type = "instance"
    lb_tg_health_check_endabled = true
    lb_tg_health_check_path = "/"
    lb_tg_health_check_protocol = "HTTP"
  }]

  lb_listener_values = [{
      lb_listener_port = "80"
      lb_listener_protocol = "HTTP"
      lb_listener_default_action_type = "forward"
      lb_listener_default_tg_name = "jitsi-http-target"
    }, {
      lb_listener_port = "443"
      lb_listener_protocol = "HTTPS"
      lb_listener_default_action_type = "forward"
      lb_listener_default_tg_name = "jitsi-http-target"
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
  ecs_service_name = "test-jitsi-service"
  ecs_cluster_id = module.ecs_cluster.ecs_cluster_id
  ecs_service_desired_count = 1

  ecs_service_lb_tg_arn = module.ecs_lb.aws_lb_target_groups.jitsi-http-target.arn
  ecs_service_lb_container_name = "web"
  ecs_service_lb_contaiener_port = 80
}

// Task definition from matrix prod or staging
module "ecs_task_definitions_matrix" {
  source = "./modules/ecs_task_definition"

  ecs_task_values  = var.ecs_task_values_matrix
  file_system_id   = "fs-08fe793123d2b34c1" //module.efs.efs_id
  ecs_task_volumes = var.ecs_task_volumes_matrix
  
  // ECS Service values
  ecs_service_name = "test-matrix-service"
  ecs_cluster_id = module.ecs_cluster.ecs_cluster_id
  ecs_service_desired_count = 1

  ecs_service_lb_tg_arn = module.ecs_lb.aws_lb_target_groups.matrix-http-target.arn
  ecs_service_lb_container_name = "element"
  ecs_service_lb_contaiener_port = 8080
}
