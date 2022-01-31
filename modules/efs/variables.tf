variable "efs_id" {
  type = string
}

variable "efs_subnet_ids" {
  type = list(string)
}

variable "efs_security_groups" {
  type = list(string)
}
