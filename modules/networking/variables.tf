variable "aws_vpc_id" {
  type = string
}

variable "cidr_block" {
  type = list(string)
}

variable "ecs_sq_values" {
  type = list(object({
    name                     = string
    description              = string
    vpc_id                   = string
    ingress_description      = string
    ingress_from_port        = number
    ingress_to_port          = number
    ingress_protocol         = string
    ingress_cidr_blocks      = list(string)
    ingress_ipv6_cidr_blocks = list(string)
    egress_from_port         = number
    egress_to_port           = number
    egress_protocol          = string
    egress_cidr_blocks       = list(string)
    egress_ipv6_cidr_blocks  = list(string)
  }))
}