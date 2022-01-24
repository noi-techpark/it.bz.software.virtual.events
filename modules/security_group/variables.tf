variable "aws_vpc_id" {
  type = string
}

variable "sg_values" {
  type = map(any)
}

variable "sg_ingress_values" {
  type = list(object({
    ingress_description     = string
    ingress_from_port       = number
    ingress_to_port         = number
    ingress_protocol        = string
    ingress_cidr_blocks     = list(string)
    ingress_security_groups = list(string)
  }))
}

variable "sg_egress_values" {
  type = list(object({
    egress_from_port   = number
    egress_to_port     = number
    egress_protocol    = string
    egress_destination = list(string)
  }))
}