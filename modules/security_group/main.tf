resource "aws_security_group" "sg" {
  //for_each    = { for sq_value in var.sq_values : sq_value.name => sq_value }
  name        = var.sg_values.name
  description = var.sg_values.description
  vpc_id      = var.aws_vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress_values
    content {
      description     = ingress.value.ingress_description
      from_port       = ingress.value.ingress_from_port
      to_port         = ingress.value.ingress_to_port
      protocol        = ingress.value.ingress_protocol
      cidr_blocks     = ingress.value.ingress_cidr_blocks     //contains(ingress.value.ingress_source, "/") ? ingress.value.ingress_source : null
      security_groups = ingress.value.ingress_security_groups //contains(ingress.value.ingress_source, "sg-") ? ingress.value.ingress_source : null
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_values
    content {
      from_port   = egress.value.egress_from_port
      to_port     = egress.value.egress_to_port
      protocol    = egress.value.egress_protocol
      cidr_blocks = egress.value.egress_destination
    }
  }

  tags = {
    Name = "test"
  }
}