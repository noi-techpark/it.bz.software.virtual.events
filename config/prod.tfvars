region = "eu-west-1"

# Tagging
default_tags = {
  Environment = "Production"
  Responsible = "Ebcont"
  Owner       = "NOI"
  Porject     = "ECS Cluster"
  Info        = "Terraform"
}

# efs for production
efs_id = ""

# Subnet and Security Group Values
aws_vpc_id = "vpc-f57aea91"
subnet_values = [{
  subnet_name = "jitsi-matrix-subnet-1-production"
  az          = "eu-west-1a",
  cidr_block  = "172.31.48.32/28" // 172.31.0.0
  }, {
  subnet_name = "jitsi-matrix-subnet-2-production"
  az          = "eu-west-1b",
  cidr_block  = "172.31.48.48/28"
}]

ecs_iam_role_name = "jitsi-matrix-agent-production"

ecs_iam_instance_profile_name = "jitsi-matrix-agent-production"

# Name value has to be Unique
alb_sg_values = {
  name        = "jitsi-matrix-alb-sg-production"
  description = "jitsi matrix alb sg production"
}

ecs_sg_values = {
  name        = "jitsi-matrix-ecs-sg-production"
  description = "jitsi matrix ecs sg production"
}

efs_sg_values = {
  name        = "jitsi-matrix-efs-sg-production"
  description = "jitsi matrix efs sg production"
}

# EC2 autoscaling and launch configuration values for ECS service
ecs_lc_image_id                   = "ami-06bb94c46ddc47feb" //"ami-0e8f6957a4eb67446"
ecs_lc_instance_type              = "c5.large"
ecs_asg_name                      = "jitsi-matrix-asg-production"
ecs_asg_desired_capacity          = 1
ecs_asg_min_size                  = 1
ecs_asg_max_size                  = 2
ecs_asg_health_check_grace_period = 300
ecs_asg_health_check_type         = "EC2"

# ALB values
lb_name                = "jitsi-matrix-alb-production"
lb_internal            = false
lb_type                = "application"
lb_deletion_protection = false

# LB target group names
lb_tg_name_jitsi   = "jitsi-http-target-production"
lb_tg_name_element = "element-http-target-production"
lb_tg_name_synapse = "synapse-http-target-production"

# LB HTTPS listener pecific values
lb_listener_ssl_policy = "ELBSecurityPolicy-2016-08"
lb_listener_cert_arn   = ""

# URLs needed for ELB and Route53
jitsi_url   = "jitsi.virtual.software.bz.it"
matrix_url  = "matrix.virtual.software.bz.it"
synapse_url = "synapse.virtual.software.bz.it"
element_url = "element.virtual.software.bz.it"

route53_zone_id = ""

# ECS Cluster Name
ecs_cluster_name = "jitsi-matrix-cluster-production"

# jitsi meet task production variables
ecs_task_values_jitsi = {
  ecs_task_name              = "jitsi-meet-task-production"
  container_definitions_path = "./modules/ecs_task_definition/container_definition_json/jitsi-meet-task.json"
  efs_volume                 = true
  requires_compatibilities   = "EC2"
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

# matrix task production variables
ecs_task_values_matrix = {
  ecs_task_name              = "matrix-task-production"
  container_definitions_path = "./modules/ecs_task_definition/container_definition_json/matrix-task.json"
  efs_volume                 = true
  requires_compatibilities   = "EC2"
}

# ECS service names
ecs_service_name_jitsi  = "jitsi-service-production"
ecs_service_name_matrix = "matrix-service-production"

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
