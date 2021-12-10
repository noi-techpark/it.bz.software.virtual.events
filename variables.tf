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

// VPN ID
variable "aws_vpc_id" {
  type = string
}

// Subnet CIDRs
variable "subnet_values" {
  type = list(map(any))
}

// Subnet ingress/egress values
variable "ecs_sg_values" {
  type = map(any)
}

variable "ecs_sg_ingress_values" {
  type = list(object({
    ingress_description      = string
    ingress_from_port        = number
    ingress_to_port          = number
    ingress_protocol         = string
    ingress_cidr_blocks      = list(string)
    ingress_ipv6_cidr_blocks = list(string)
  }))
}

variable "ecs_sg_egress_values" {
  type = list(object({
    egress_from_port        = number
    egress_to_port          = number
    egress_protocol         = string
    egress_cidr_blocks      = list(string)
    egress_ipv6_cidr_blocks = list(string)
  }))
}

# ECS Cluster
#variable "ecs_cluster_name" {
#  type = string
#}

# EC2 instance

#variable "ec2_instance_type" {
#  type = string
#}
