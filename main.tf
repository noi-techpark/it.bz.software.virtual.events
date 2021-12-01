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

// Task definition from jitsi meet prod or staging
module "ecs_task_definitions_jitsi" {
  source = "./modules/ecs_task_definition"

  ecs_task_values = var.ecs_task_values_jitsi
  ecs_task_volumes = var.ecs_task_volumes_jitsi
}

// Task definition from matrix prod or staging
module "ecs_task_definitions_matrix" {
  source = "./modules/ecs_task_definition"

  ecs_task_values = var.ecs_task_values_matrix
  ecs_task_volumes = var.ecs_task_volumes_matrix
}

#module "ecs" {
#  source = "./modules/ecs"
#  ecs_cluster_name = var.ecs_cluster_name
#}

#module "efs" {
#    source = "./modules/efs"
#    efs_name = var.efs_name
#    efs_id = var.efs_id
#    efs_performance_mode = var.efs_performance_mode
#    efs_default_backup = var.efs_default_backup
#    efs_throughput_mode = var.efs_throughput_mode
#    efs_encrypted = var.efs_encrypted
#    efs_backup_policy = var.efs_backup_policy
#}

#module "ec2" {
#    source  = "./modules/ec2"
#    ec2_ami = " amzn2-ami-ecs-hvm-2.0.20210916-x86_64-ebs"
#    ec2_instance_type = var.ec2_instance_type
#    depends_on = [
#      module.efs
#    ]
#}
