variable "ecs_lc_image_id" {
  type = string
}

variable "ecs_lc_iam_profile" {
  type = string
}

variable "ecs_lc_sg" {
  type = list(string)
}

variable "ecs_lc_user_data" {
  type = string
}

variable "ecs_lc_instance_type" {
  type = string
}

variable "ecs_ec2_depends_on" {
  type = list(any)
}

variable "ecs_asg_name" {
  type = string
}

variable "ecs_asg_vpc_zone_identifier" {
  type = list(string)
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

  default = "EC2"
}
