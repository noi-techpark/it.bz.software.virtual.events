variable "lb_name" {
  type = string
}

variable "lb_internal" {
  type = string
}

variable "lb_type" {
  type = string
}

variable "lb_sg" {
  type = list(string)
}

variable "lb_subnet" {
  type = list(string)
}

variable "lb_deletion_protection" {
  type = string
}

variable "lb_tg_values" {
  type = list(object({
    lb_tg_name = string
    lb_tg_port = number
    lb_tg_protocol = string
    lb_tg_vpc = string
    lb_tg_target_type = string
    lb_tg_health_check_endabled = bool
    lb_tg_health_check_path = string
    lb_tg_health_check_protocol = string
  }))
}

variable "lb_listener_values" {
  type = list(object({
    lb_listener_port = string
    lb_listener_protocol = string
    lb_listener_default_action_type = string
    lb_listener_default_tg_name = string
  }))
}

#variable "lb_tg_target_type" {
#  type = string
#}
#
#variable "lb_tga_arn" {
#  type = string
#}
#
#variable "lb_tga_id" {
#  type = string
#}
#
#variable "lb_tga_port" {
#  type = string
#}
