variable "ecs_task_values" {
  type = map(any)

  default = {
    ecs_task_name              = "test_task"
    container_definitions_path = "container_definition_json/test.json"
    efs_volume                 = false
  }
}

variable "ecs_task_volumes" {
  type = list(map(any))

  default = [{
    name                     = "test-storage1"
    file_system_id           = "fs-111111"
    root_directory           = "/root/"
    transit_encryption       = "DISABLED"
    authorization_config_iam = "DISABLED"
    }, {
    name                     = "test-storage1"
    file_system_id           = "fs-222222"
    root_directory           = "/home/"
    transit_encryption       = "DISABLED"
    authorization_config_iam = "DISABLED"
  }]
}
