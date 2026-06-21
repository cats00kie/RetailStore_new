output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "VPC CIDR block"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "Private subnet IDs"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public subnet IDs"
}

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "DNS name of the Application Load Balancer"
}

output "alb_arn" {
  value       = aws_lb.main.arn
  description = "ARN of the Application Load Balancer"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "ECS cluster name"
}

output "ecs_cluster_arn" {
  value       = aws_ecs_cluster.main.arn
  description = "ECS cluster ARN"
}

output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "PostgreSQL RDS endpoint"
}

output "rds_address" {
  value       = aws_db_instance.postgres.address
  description = "PostgreSQL RDS address (hostname)"
}

output "rds_port" {
  value       = aws_db_instance.postgres.port
  description = "PostgreSQL RDS port"
}

output "elasticache_redis_endpoint" {
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
  description = "ElastiCache Redis endpoint"
}

output "elasticache_redis_port" {
  value       = aws_elasticache_cluster.redis.port
  description = "ElastiCache Redis port"
}

output "iam_role_ecs_task_execution_arn" {
  value       = aws_iam_role.ecs_task_execution_role.arn
  description = "ECS task execution IAM role ARN"
}

output "iam_role_ecs_task_arn" {
  value       = aws_iam_role.ecs_task_role.arn
  description = "ECS task IAM role ARN"
}

output "application_url" {
  value       = "http://${aws_lb.main.dns_name}"
  description = "Application URL"
}

output "admin_panel_url" {
  value       = "http://${aws_lb.main.dns_name}:8081"
  description = "Admin panel URL"
}

output "cloudwatch_log_group_names" {
  value       = { for service in keys(var.container_images) : service => aws_cloudwatch_log_group.ecs[service].name }
  description = "CloudWatch log group names for each service"
}
