resource "aws_ecs_task_definition" "noi-ecs-task-definition" {
  family                = var.ecs_task_values.ecs_task_name
  container_definitions = file(var.ecs_task_values.container_definitions_path)

  dynamic "volumes" {
    for_each = var.ecs_task_volumes
    iterator = "volumes"
    content {
    	volume {
    	  name  = volumes.value["name"]
  	
    	  efs_volume_configuration {
    	    file_system_id     = volumes.value["file_system_id"]
    	    root_directory     = volumes.value["root_directory"]
    	    transit_encryption = volumes.value["transit_encryption"]
    	    authorization_config {
    	      iam = "DISABLED"
    	    }
    	  }
    	}
    }
  }
}
