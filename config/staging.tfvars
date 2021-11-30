region = "eu-west-1"

//jitsi meet task staging variables


// matrix task staging variables


#ecs_cluster_name = "jitsi-cluster-staging"
#ec2_instance_type = "c5a.large"
#efs_name = "jitsi-matrix-efs-staging"
#efs_id = "fs-bce67e88"
#efs_default_backup = "enabled"
#efs_backup_policy = "DISABLED"
#efs_performance_mode = "generalPurpose"
#efs_throughput_mode = "bursting"
#efs_encrypted = "true"