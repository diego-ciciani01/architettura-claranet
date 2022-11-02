# resource "aws_rds_cluster" "aurora_cluster" {
#   cluster_identifier      = "aurora-cluster"
#   engine                  = "aurora-mysql"
#   engine_version          = "5.7.mysql_aurora.2.03.2"
#   availability_zones      = var.availability_zones
#   database_name           = "mydb"
#   master_username         = "user"
#   master_password         = "password"
#   backup_retention_period = 5
#   preferred_backup_window = "07:00-09:00"
# }

