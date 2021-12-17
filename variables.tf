variable "region" {
  type = string
}

variable "default_tags" {
  type = map(string)
}

# EFS values
variable "efs_name" {
  type = string
}

# EFS values
variable "efs_id" {
  type = string
}

# VPN ID
variable "aws_vpc_id" {
  type = string
}

# Subnet CIDRs
variable "subnet_values" {
  type = list(map(any))
}

variable "ecs_iam_role_name" {
  type = string
}

variable "ecs_iam_instance_profile_name" {
  type = string
}

# Subnet ingress/egress values
variable "alb_sg_values" {
  type = map(any)
}

# Subnet ingress/egress values
variable "ecs_sg_values" {
  type = map(any)
}

# EC2 launch configuration values for ECS service
variable "ecs_lc_image_id" {
  type = string
}

variable "ecs_lc_user_data" {
  type = string
}

variable "ecs_lc_instance_type" {
  type = string
}

# EC2 autoscaling configuration values for ECS service
variable "ecs_asg_name" {
  type = string
}

variable "ecs_asg_desired_capacity" {
  type = number
}

variable "ecs_asg_min_size" {
  type = number
}

variable "ecs_asg_max_size" {
  type = number
}

variable "ecs_asg_health_check_grace_period" {
  type = number
}

variable "ecs_asg_health_check_type" {
  type = string
}

# ALB values
variable "lb_name" {
  type = string
}

variable "lb_internal" {
  type = bool
}

variable "lb_type" {
  type = string
}

variable "lb_deletion_protection" {
  type = bool
}

# LB target group names
variable "lb_tg_name_jitsi" {
  type = string
}

variable "lb_tg_name_element" {
  type = string
}

variable "lb_tg_name_synapse" {
  type = string
}

# LB HTTPS listener pecific values
variable "lb_listener_ssl_policy" {
  type = string
}

variable "lb_listener_cert_arn" {
  type = string
}

# LB listener rule specific values
variable "lb_listener_rule_condition_host_header_matrix-synapse" {
  type = list(string)
}

variable "lb_listener_rule_condition_host_header_element" {
  type = list(string)
}

# ECS Cluster
variable "ecs_cluster_name" {
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

# ECS service names
variable "ecs_service_name_jitsi" {
  type = string
}

variable "ecs_service_name_matrix" {
  type = string
}
