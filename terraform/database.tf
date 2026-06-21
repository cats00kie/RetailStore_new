# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  identifier     = "${var.app_name}-db"
  engine         = "postgres"
  engine_version = "16.1"
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = "retaildb"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name            = aws_db_subnet_group.main.name
  publicly_accessible             = false
  vpc_security_group_ids           = [aws_security_group.rds.id]
  parameter_group_name             = aws_db_parameter_group.postgres.name
  backup_retention_period          = 7
  backup_window                    = "03:00-04:00"
  maintenance_window               = "mon:04:00-mon:05:00"
  enabled_cloudwatch_logs_exports  = ["postgresql"]
  skip_final_snapshot              = var.environment == "dev" ? true : false
  final_snapshot_identifier        = var.environment == "dev" ? null : "${var.app_name}-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  deletion_protection              = false
  copy_tags_to_snapshot            = true
  auto_minor_version_upgrade       = true
  multi_az                         = false # Set to true for production

  tags = {
    Name = "${var.app_name}-postgres"
  }

  depends_on = [aws_db_subnet_group.main]
}

# RDS Parameter Group for PostgreSQL
resource "aws_db_parameter_group" "postgres" {
  family      = "postgres16"
  name        = "${var.app_name}-postgres-params"
  description = "Custom parameter group for ${var.app_name}"

  tags = {
    Name = "${var.app_name}-postgres-params"
  }
}
