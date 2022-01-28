resource "aws_efs_mount_target" "efs_mount_targets" {
  count           = length(var.efs_subnet_ids)
  file_system_id  = var.efs_id
  subnet_id       = var.efs_subnet_ids[count.index]
  security_groups = var.efs_security_groups
}