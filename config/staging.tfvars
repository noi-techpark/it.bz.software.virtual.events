region = "eu-west-1"

//jitsi meet task staging variables
ecs_task_values_jitsi = {
    ecs_task_name              = "jitsi-meet-task-staging"
    container_definitions_path = "./modules/ecs_task_definition/container_definition_json/jitsi-meet-task-staging.json"
    efs_volume                 = true
  }

  ecs_task_volumes_jitsi = [{
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

// matrix task staging variables
ecs_task_values_matrix = {
    ecs_task_name              = "matrix-task-staging"
    container_definitions_path = "./modules/ecs_task_definition/container_definition_json/matrix-task-staging.json"
    efs_volume                 = true
  }

ecs_task_volumes_matrix = [{
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

#ecs_cluster_name = "jitsi-cluster-staging"
#ec2_instance_type = "c5a.large"
#efs_name = "jitsi-matrix-efs-staging"
#efs_id = "fs-bce67e88"
#efs_default_backup = "enabled"
#efs_backup_policy = "DISABLED"
#efs_performance_mode = "generalPurpose"
#efs_throughput_mode = "bursting"
#efs_encrypted = "true"