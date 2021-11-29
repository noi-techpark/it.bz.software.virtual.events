resource "aws_efs_file_system" "fs" {
  creation_token = "my-product"

  tags = {
    Name = var.efs_name
    "aws:elasticfilesystem:default-backup" = var.efs_default_backup
  }

  id = var.efs_id
  performance_mode = var.efs_performance_mode
  throughput_mode = var.efs_throughput_mode
  encrypted = var.efs_encrypted
}


resource "aws_efs_backup_policy" "policy" {
    file_system_id = aws_efs_file_system.fs.id

    backup_policy {
      status = var.efs_backup_policy
    }
}