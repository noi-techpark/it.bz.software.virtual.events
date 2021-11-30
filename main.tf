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

  ecs_task_values = {
    ecs_task_name              = "jitsi-meet-task-staging"
    container_definitions_path = "container_definition_json/jitsi-meet-task-staging.json"
    efs_volume                 = true
  }

  ecs_task_volumes = [{
    name                     = "jitsi-data"
    file_system_id           = "fs-bce67e88"
    root_directory           = "/prosody/config"
    transit_encryption       = "DISABLED"
    authorization_config_iam = "DISABLED"
    }, {
    name                     = "jitsi-images"
    file_system_id           = "fs-bce67e88"
    root_directory           = "/jitsi/jitsi-meet/images"
    transit_encryption       = "DISABLED"
    authorization_config_iam = "DISABLED"
  }]
}

// Task definition from matrix prod or staging
module "ecs_task_definitions_matrix" {
  source = "./modules/ecs_task_definition"

  ecs_task_values = {
    ecs_task_name              = "matrix-task-staging"
    container_definitions_path = "container_definition_json/matrix-task-staging.json"
    efs_volume                 = true
  }

  ecs_task_volumes = [{
    name                     = "matrix-synapse-data"
    file_system_id           = "fs-bce67e88"
    root_directory           = "/matrix/synapse"
    transit_encryption       = "DISABLED"
    authorization_config_iam = "DISABLED"
    }, {
    name                     = "matrix-postres-data"
    file_system_id           = "fs-bce67e88"
    root_directory           = "/matrix/postgres/data"
    transit_encryption       = "DISABLED"
    authorization_config_iam = "DISABLED"
    }, {
    name                     = "matrix-element-data"
    file_system_id           = "fs-bce67e88"
    root_directory           = "/matrix/element"
    transit_encryption       = "DISABLED"
    authorization_config_iam = "DISABLED"
  }]
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

