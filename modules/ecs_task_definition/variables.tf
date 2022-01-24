variable "ecs_task_values" {
  type = map(any)
}

variable "ecs_task_volumes" {
  type = list(map(any))

  default = []
}

variable "file_system_id" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "ecs_service_desired_count" {
  type = number

  default = 1
}

variable "ecs_service_lb_values" {
  type = list(object({
    ecs_service_lb_tg_arn          = string
    ecs_service_lb_container_name  = string
    ecs_service_lb_contaiener_port = number
  }))
}
