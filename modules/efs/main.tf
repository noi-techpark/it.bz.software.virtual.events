resource "aws_efs_file_system" "efs_fs" {
  creation_token   = var.efs_name
  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode
  encrypted        = var.efs_encrypted
  kms_key_id       = var.efs_kmsKeyId

  tags = {
    Name                                   = var.efs_name
    "aws:elasticfilesystem:default-backup" = var.efs_backup_policy_status
  }
}

resource "aws_efs_access_point" "efs_access_point" {
  for_each       = { for task_volume in var.ecs_task_volumes_concat : task_volume.root_directory => task_volume }
  file_system_id = aws_efs_file_system.efs_fs.id
  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = 666
    }
    path = each.value.root_directory
  }
}

#resource "aws_efs_backup_policy" "policy" {
#    file_system_id = aws_efs_file_system.efs_fs.id
#
#    backup_policy {
#      status = var.efs_backup_policy_status
#    }
#}
