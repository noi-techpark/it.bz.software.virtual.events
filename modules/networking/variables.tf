variable "aws_vpc_id" {
  type = string
}

variable "subnet_values" {
  type = list(map(any))
}
