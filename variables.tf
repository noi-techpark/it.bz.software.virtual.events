variable "region" {
  type = string
}

variable "ecs_task_values_jitsi" {
  type = map(any)
}

variable "ecs_task_volumes_jitsi" {
  type = list(map(any))
}

variable "ecs_task_values_matrix" {
  type = map(any)
}

variable "ecs_task_volumes_matrix" {
  type = list(map(any))
}

# ECS Cluster

#variable "ecs_cluster_name" {
#  type = string
#}

# EC2 instance

#variable "ec2_instance_type" {
#  type = string
#}

# EFS

#variable "efs_name" {
#  type = string
#}

#variable "efs_id" {
#  type = string
#}

#variable "efs_default_backup" {
#  type = string
#}

#variable "efs_performance_mode" {
#  type = string
#}

#variable "efs_throughput_mode" {
#  type = string
#}

#variable "efs_encrypted" {
#  type = string
#}

#variable "efs_backup_policy" {
#  type = string
#}