region = "eu-central-1"

// efs for staging
efs_name = "jitsi-matrix-efs-staging"


// Subnet and Security Group Values
aws_vpc_id = "vpc-f63fc59c"
cidr_block = ["172.31.48.0/28", "172.31.48.16/28"]

// Name value has to be Unique
ecs_sg_values = {
  name                     = "sg-test-1"
  description              = "test sg"
}

ecs_sg_ingress_values = [{
  ingress_description      = "https test"
  ingress_from_port        = 443
  ingress_to_port          = 443
  ingress_protocol         = "tcp"
  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_ipv6_cidr_blocks = ["0.0.0.0/0"]
  }, {
  ingress_description      = "http test"
  ingress_from_port        = 80
  ingress_to_port          = 80
  ingress_protocol         = "tcp"
  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_ipv6_cidr_blocks = ["0.0.0.0/0"]
}, {
  ingress_description      = "ssh test"
  ingress_from_port        = 22
  ingress_to_port          = 22
  ingress_protocol         = "tcp"
  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_ipv6_cidr_blocks = ["0.0.0.0/0"]
}]

ecs_sg_egress_values = [{
  egress_from_port         = 0
  egress_to_port           = 0
  egress_protocol          = "-1"
  egress_cidr_blocks       = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks  = ["::/0"]
}]

# jitsi meet task staging variables
ecs_task_values_jitsi = {
  ecs_task_name              = "jitsi-meet-task-staging"
  container_definitions_path = "./modules/ecs_task_definition/container_definition_json/jitsi-meet-task-staging.json"
  efs_volume                 = true
}

ecs_task_volumes_jitsi = [{
  name                     = "jitsi-data"
  root_directory           = "/prosody/config"
  transit_encryption       = "DISABLED"
  authorization_config_iam = "DISABLED"
  }, {
  name                     = "jitsi-images"
  root_directory           = "/jitsi/jitsi-meet/images"
  transit_encryption       = "DISABLED"
  authorization_config_iam = "DISABLED"
}]

# matrix task staging variables
ecs_task_values_matrix = {
  ecs_task_name              = "matrix-task-staging"
  container_definitions_path = "./modules/ecs_task_definition/container_definition_json/matrix-task-staging.json"
  efs_volume                 = true
}

ecs_task_volumes_matrix = [{
  name                     = "matrix-synapse-data"
  root_directory           = "/matrix/synapse"
  transit_encryption       = "DISABLED"
  authorization_config_iam = "DISABLED"
  }, {
  name                     = "matrix-postres-data"
  root_directory           = "/matrix/postgres/data"
  transit_encryption       = "DISABLED"
  authorization_config_iam = "DISABLED"
  }, {
  name                     = "matrix-element-data"
  root_directory           = "/matrix/element"
  transit_encryption       = "DISABLED"
  authorization_config_iam = "DISABLED"
}]

#ecs_cluster_name = "jitsi-cluster-staging"
#ec2_instance_type = "c5a.large"