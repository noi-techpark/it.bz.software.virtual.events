resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                = var.ecs_task_values.ecs_task_name
  container_definitions = file(var.ecs_task_values.container_definitions_path)

  dynamic "volume" {
    for_each = var.ecs_task_volumes
    content {
      name = volume.value["name"]
  
      efs_volume_configuration {
        file_system_id     = var.file_system_id
        root_directory     = volume.value["root_directory"]
        transit_encryption = volume.value["transit_encryption"]
      }
    }
  }
}

resource "aws_ecs_service" "worker" {
  name            = var.ecs_service_name //"name"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.ecs_service_desired_count //1
  load_balancer {
    target_group_arn = var.ecs_service_lb_tg_arn
    container_name = var.ecs_service_lb_container_name
    container_port = var.ecs_service_lb_contaiener_port
  }
}
