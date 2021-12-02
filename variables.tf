variable "region" {
  type = string
}

# ECS Task values
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

// EFS values
variable "efs_name" {
  type = string
}

# ECS Cluster
#variable "ecs_cluster_name" {
#  type = string
#}

# EC2 instance

#variable "ec2_instance_type" {
#  type = string
#}
