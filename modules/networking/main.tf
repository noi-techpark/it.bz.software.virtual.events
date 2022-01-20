resource "aws_subnet" "subnet" {
  for_each          = { for subnet in var.subnet_values : subnet.cidr_block => subnet }
  vpc_id            = var.aws_vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = "${each.value.subnet_name}"
  }
}
