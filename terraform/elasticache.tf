# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.app_name}-redis-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.app_name}-redis-subnet-group"
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.app_name}-redis"
  description                = "${var.app_name} Redis"

  engine                     = "redis"
  engine_version             = "7.0"
  node_type                  = var.redis_node_type

  num_cache_clusters         = 2

  automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.redis.id]

  parameter_group_name       = aws_elasticache_parameter_group.redis.name

  apply_immediately          = true
}

# ElastiCache Parameter Group for Redis
resource "aws_elasticache_parameter_group" "redis" {
  name        = "${var.app_name}-redis-params"
  family      = "redis7"
  description = "Custom parameter group for ${var.app_name} Redis"

  tags = {
    Name = "${var.app_name}-redis-params"
  }
}

# CloudWatch Log Group for Redis
resource "aws_cloudwatch_log_group" "redis" {
  name              = "/aws/elasticache/${var.app_name}-redis"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.app_name}-redis-logs"
  }
}
