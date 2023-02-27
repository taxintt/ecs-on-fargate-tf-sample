resource "aws_secretsmanager_secret" "database" {
  name        = "sbcntr/mysql"
  description = "secret for sbcntr-db"

  tags = {
    Name = "sbcntr-mysql"
  }
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id     = aws_secretsmanager_secret.database.id
  secret_string = jsonencode(local.database_secret)
}

locals {
  # see tmp/setup.sql
  database_secret = {
    engine   = "mysql"
    host     = aws_rds_cluster.aurora.endpoint
    username = "sbcntruser"
    password = "sbcntrEncP"
    dbname   = "sbcntrapp"
  }
}