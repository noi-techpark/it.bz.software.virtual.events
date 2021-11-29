variable "region" {
    type = string
}

# Cluster

variable "cluster_name" {
    type = string
}

# EC2 instance

variable "ec2_instance_type" {
    type = string
}

# EFS

variable "efs_name" {
    type = string
}

variable "efs_id" {
    type = string
}

variable "efs_default_backup" {
    type = string
}

variable "efs_performance_mode" {
    type = string
}

variable "efs_throughput_mode" {
    type = string
}

variable "efs_encrypted" {
    type = string
}

variable "efs_backup_policy" {
    type = string
}