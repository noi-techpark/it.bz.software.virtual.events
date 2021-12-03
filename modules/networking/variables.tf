variable "aws_vpc_id" {
  type = string
}

variable "cidr_block" {
  type = list(string)
}

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
    egress_from_port         = number
    egress_to_port           = number
    egress_protocol          = string
    egress_cidr_blocks       = list(string)
    egress_ipv6_cidr_blocks  = list(string)
  }))
}