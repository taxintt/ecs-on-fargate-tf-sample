# aws rds cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "sbcntr-db"
  engine             = "aurora-mysql"
  engine_mode        = "provisioned"
  # INFO: check aurora engine version by using the below command
  # aws rds describe-db-engine-versions --engine aurora-mysql --query 'DBEngineVersions[].EngineVersion'
  engine_version = "5.7.mysql_aurora.2.11.1"

  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.aurora.name

  iam_database_authentication_enabled = false
  database_name                       = "sbcntrapp"
  port                                = 3306
  master_username                     = "admin"
  master_password                     = "admintest"

  db_cluster_parameter_group_name  = "default.aurora-mysql5.7"
  db_instance_parameter_group_name = "default.aurora-mysql5.7"

  backup_retention_period = 1
  preferred_backup_window = "05:00-07:00"
  storage_encrypted       = true
  copy_tags_to_snapshot   = true

  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
  skip_final_snapshot             = true
  deletion_protection             = false

  backtrack_window = 0

  tags = {
    Name = "sbcntr-db"
  }
}

# aws rds cluster instance
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance
resource "aws_rds_cluster_instance" "instance" {
  count              = 2
  cluster_identifier = aws_rds_cluster.aurora.id
  identifier         = "sbcntr-db-${count.index}"
  instance_class     = "db.t3.small"

  engine         = aws_rds_cluster.aurora.engine
  engine_version = aws_rds_cluster.aurora.engine_version

  db_subnet_group_name = aws_db_subnet_group.aurora.name
  publicly_accessible  = false

  monitoring_role_arn = aws_iam_role.aurora.arn
  monitoring_interval = 60

  auto_minor_version_upgrade   = true
  preferred_maintenance_window = "Sat:17:00-Sat:17:30"
  promotion_tier               = 0

  tags = {
    Name = "sbcntr-db-${count.index}"
  }
}