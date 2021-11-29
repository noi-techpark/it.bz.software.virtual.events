resource "aws_instance" "instance" {
  instance_type = var.ec2_instance_type
}