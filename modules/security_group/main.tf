resource "aws_security_group" "sg" {
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
      cidr_blocks     = ingress.value.ingress_cidr_blocks
      security_groups = ingress.value.ingress_security_groups
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