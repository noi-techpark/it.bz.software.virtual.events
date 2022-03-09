region = "eu-west-1"

# Tagging
default_tags = {
  Environment = "Staging"
  Responsible = "Ebcont"
  Owner       = "NOI"
  Project     = "ECS Cluster"
  Info        = "Terraform"
}

# set to true, if postgreSQL upgrade will be done
# this will deactivate the matrix-service and 
# active just the postgresql-service
postgresql_upgrade = false

# efs for staging
efs_id = "fs-bce67e88"

# Subnet and Security Group Values
aws_vpc_id = "vpc-f57aea91"
subnet_values = [{
  subnet_name = "jitsi-matrix-subnet-1-staging"
  az          = "eu-west-1a",
  cidr_block  = "172.31.48.0/28"
  }, {
  subnet_name = "jitsi-matrix-subnet-2-staging"
  az          = "eu-west-1b",
  cidr_block  = "172.31.48.16/28"
}]

ecs_iam_role_name = "jitsi-matrix-agent-staging"

ecs_iam_instance_profile_name = "jitsi-matrix-agent-staging"

# Name value has to be Unique
alb_sg_values = {
  name        = "jitsi-matrix-alb-sg-staging"
  description = "jitsi matrix alb sg staging"
}

ecs_sg_values = {
  name        = "jitsi-matrix-ecs-sg-staging"
  description = "jitsi matrix ecs sg staging"
}

efs_sg_values = {
  name        = "jitsi-matrix-efs-sg-staging"
  description = "jitsi matrix efs sg staging"
}

# EC2 autoscaling and launch configuration values for ECS service
ecs_lc_image_id                   = "ami-06bb94c46ddc47feb"
ecs_lc_instance_type              = "c5a.large"
ecs_lc_key                        = "jitsi-cluster-key"
ecs_asg_name                      = "jitsi-matrix-asg-staging"
ecs_asg_desired_capacity          = 1
ecs_asg_min_size                  = 1
ecs_asg_max_size                  = 1
ecs_asg_health_check_grace_period = 300
ecs_asg_health_check_type         = "EC2"

# ALB values
lb_name                = "jitsi-matrix-alb-staging"
lb_internal            = false
lb_type                = "application"
lb_deletion_protection = false

# LB target group names
lb_tg_name_jitsi   = "jitsi-http-target-staging"
lb_tg_name_element = "element-http-target-staging"
lb_tg_name_synapse = "synapse-http-target-staging"

# LB HTTPS listener pecific values
lb_listener_ssl_policy = "ELBSecurityPolicy-2016-08"
lb_listener_cert_arn   = "arn:aws:acm:eu-west-1:755952719952:certificate/f96dc200-2a69-4a5d-bcaa-c57dfa5367ea"

# URLs needed for ELB and Route53
jitsi_url   = "jitsi.virtual.software.testingmachine.eu"
matrix_url  = "matrix.virtual.software.testingmachine.eu"
synapse_url = "synapse.virtual.software.testingmachine.eu"
element_url = "element.virtual.software.testingmachine.eu"

route53_zone_id = "Z3R834M85QA828"

# ECS Cluster Name
ecs_cluster_name = "jitsi-matrix-cluster-staging"

# jitsi meet task staging variables
ecs_task_values_jitsi = {
  ecs_task_name              = "jitsi-meet-task-staging"
  container_definitions_path = "./modules/ecs_task_definition/container_definition_json/jitsi-meet-task-staging.tftpl"
  efs_volume                 = true
  requires_compatibilities   = "EC2"
  docker_host_address        = ""
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
  container_definitions_path = "./modules/ecs_task_definition/container_definition_json/matrix-task-staging.tftpl"
  efs_volume                 = true
  requires_compatibilities   = "EC2"
  docker_host_address        = ""
}

# ECS service names
ecs_service_name_jitsi  = "jitsi-service-staging"
ecs_service_name_matrix = "matrix-service-staging"

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
