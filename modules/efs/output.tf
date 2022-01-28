output "efs_mount_target_ids" {
  value = toset([
    for efs_mount_target in aws_efs_mount_target.efs_mount_targets : efs_mount_target.id
  ])
}
