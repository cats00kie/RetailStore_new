output "alb_dns_name" {
  description = "DNS del ALB (solo cuando create_alb = true)"
  value       = var.create_alb ? aws_lb.this[0].dns_name : null
}

output "alb_arn" {
  description = "ARN del ALB (solo cuando create_alb = true)"
  value       = var.create_alb ? aws_lb.this[0].arn : null
}

output "alb_arn_suffix" {
  description = "Sufijo del ARN del ALB para métricas CloudWatch (solo cuando create_alb = true)"
  value       = var.create_alb ? aws_lb.this[0].arn_suffix : null
}

output "target_group_arn_suffix" {
  description = "Sufijo del ARN del Target Group para métricas CloudWatch (solo cuando create_alb = true)"
  value       = var.create_alb ? aws_lb_target_group.this[0].arn_suffix : null
}

output "service_name" {
  description = "Nombre del ECS service"
  value       = aws_ecs_service.this.name
}

output "security_group_id" {
  value = aws_security_group.ecs_tasks.id
}