# CloudWatch Alarms for ALB
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  count             = var.enable_monitoring ? 1 : 0
  alarm_name        = "${var.app_name}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name       = "UnHealthyHostCount"
  namespace         = "AWS/ApplicationELB"
  period            = 300
  statistic         = "Average"
  threshold         = 1
  alarm_description = "Alert when ALB has unhealthy targets"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  treat_missing_data = "notBreaching"
}

# CloudWatch Alarms for RDS CPU
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  count             = var.enable_monitoring ? 1 : 0
  alarm_name        = "${var.app_name}-rds-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name       = "CPUUtilization"
  namespace         = "AWS/RDS"
  period            = 300
  statistic         = "Average"
  threshold         = 80
  alarm_description = "Alert when RDS CPU is high"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.id
  }

  treat_missing_data = "notBreaching"
}

# CloudWatch Alarms for RDS Disk Space
resource "aws_cloudwatch_metric_alarm" "rds_free_disk" {
  count             = var.enable_monitoring ? 1 : 0
  alarm_name        = "${var.app_name}-rds-free-disk-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name       = "FreeStorageSpace"
  namespace         = "AWS/RDS"
  period            = 300
  statistic         = "Average"
  threshold         = 2147483648 # 2 GB in bytes
  alarm_description = "Alert when RDS free disk space is low"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.id
  }

  treat_missing_data = "notBreaching"
}

# CloudWatch Alarms for ElastiCache CPU
resource "aws_cloudwatch_metric_alarm" "elasticache_cpu" {
  count             = var.enable_monitoring ? 1 : 0
  alarm_name        = "${var.app_name}-elasticache-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name       = "CPUUtilization"
  namespace         = "AWS/ElastiCache"
  period            = 300
  statistic         = "Average"
  threshold         = 75
  alarm_description = "Alert when ElastiCache CPU is high"

  dimensions = {
    CacheClusterId = aws_elasticache_cluster.redis.cluster_id
  }

  treat_missing_data = "notBreaching"
}

# CloudWatch Alarms for ElastiCache Evictions
resource "aws_cloudwatch_metric_alarm" "elasticache_evictions" {
  count             = var.enable_monitoring ? 1 : 0
  alarm_name        = "${var.app_name}-elasticache-evictions"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name       = "Evictions"
  namespace         = "AWS/ElastiCache"
  period            = 300
  statistic         = "Sum"
  threshold         = 100
  alarm_description = "Alert when ElastiCache is evicting items"

  dimensions = {
    CacheClusterId = aws_elasticache_cluster.redis.cluster_id
  }

  treat_missing_data = "notBreaching"
}
