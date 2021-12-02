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
  cidr_block    = var.cidr_block
  ecs_sq_values = var.ecs_sq_values
}

/*
* EFS creation working, but paths for container mount not automatically created
* need to create access points for every EFS sub-dir or manuel/lambda creates sub-dirs
*/
module "efs" {
  source                  = "./modules/efs"
  efs_name                = var.efs_name
  ecs_task_volumes_concat = concat(var.ecs_task_volumes_jitsi, var.ecs_task_volumes_matrix)
}

// Task definition from jitsi meet prod or staging
module "ecs_task_definitions_jitsi" {
  source = "./modules/ecs_task_definition"

  ecs_task_values  = var.ecs_task_values_jitsi
  file_system_id   = module.efs.efs_id
  ecs_task_volumes = var.ecs_task_volumes_jitsi
}

// Task definition from matrix prod or staging
module "ecs_task_definitions_matrix" {
  source = "./modules/ecs_task_definition"

  ecs_task_values  = var.ecs_task_values_matrix
  file_system_id   = module.efs.efs_id
  ecs_task_volumes = var.ecs_task_volumes_matrix
}

#module "ecs" {
#  source = "./modules/ecs"
#  ecs_cluster_name = var.ecs_cluster_name
#}

#module "ec2" {
#    source  = "./modules/ec2"
#    ec2_ami = " amzn2-ami-ecs-hvm-2.0.20210916-x86_64-ebs"
#    ec2_instance_type = var.ec2_instance_type
#    depends_on = [
#      module.efs
#    ]
#}
