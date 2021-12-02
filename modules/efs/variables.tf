variable "efs_name" {
    type = string
}

variable "efs_encrypted" {
    type = string

    default = false
}

variable "efs_kmsKeyId" {
    type = string

    default = ""
}

variable "efs_performance_mode" {
    type = string

    default = "generalPurpose"
}

variable "efs_throughput_mode" {
    type = string

    default = "bursting"
}

variable "ecs_task_volumes_concat" {
  type = list(map(any))
}

variable "efs_backup_policy_status" {
    type = string

    default = "DISABLED"
}

variable "efs_backup_policy" {
    type = string

    default = ""
}
