resource "aws_subnet" "subnet" {
  for_each   = toset(var.cidr_block)
  vpc_id     = var.aws_vpc_id
  cidr_block = each.key

  tags = {
    Name = "test"
  }
}

resource "aws_security_group" "ecs_sg" {
  for_each    = { for sq_value in var.ecs_sq_values : sq_value.name => sq_value }
  name        = each.value.name
  description = each.value.description
  vpc_id      = var.aws_vpc_id

  ingress {
    description      = each.value.ingress_description
    from_port        = each.value.ingress_from_port
    to_port          = each.value.ingress_to_port
    protocol         = each.value.ingress_protocol
    cidr_blocks      = each.value.ingress_cidr_blocks
    ipv6_cidr_blocks = each.value.ingress_ipv6_cidr_blocks
  }

  egress {
    from_port        = each.value.egress_from_port
    to_port          = each.value.egress_to_port
    protocol         = each.value.egress_protocol
    cidr_blocks      = each.value.egress_cidr_blocks
    ipv6_cidr_blocks = each.value.egress_ipv6_cidr_blocks
  }

  tags = {
    Name = "test"
  }
}