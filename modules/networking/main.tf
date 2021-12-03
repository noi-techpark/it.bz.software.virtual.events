resource "aws_subnet" "subnet" {
  for_each   = toset(var.cidr_block)
  vpc_id     = var.aws_vpc_id
  cidr_block = each.key

  tags = {
    Name = "test"
  }
}

resource "aws_security_group" "ecs_sg" {
  //for_each    = { for sq_value in var.ecs_sq_values : sq_value.name => sq_value }
  name        = var.ecs_sg_values.name
  description = var.ecs_sg_values.description
  vpc_id      = var.aws_vpc_id

  dynamic "ingress" {
    for_each = var.ecs_sg_ingress_values
    content {
      description      = ingress.value.ingress_description
      from_port        = ingress.value.ingress_from_port
      to_port          = ingress.value.ingress_to_port
      protocol         = ingress.value.ingress_protocol
      cidr_blocks      = ingress.value.ingress_cidr_blocks
      ipv6_cidr_blocks = ingress.value.ingress_ipv6_cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.ecs_sg_egress_values
    content {
      from_port        = egress.value.egress_from_port
      to_port          = egress.value.egress_to_port
      protocol         = egress.value.egress_protocol
      cidr_blocks      = egress.value.egress_cidr_blocks
      ipv6_cidr_blocks = egress.value.egress_ipv6_cidr_blocks
    }
  }

  tags = {
    Name = "test"
  }
}