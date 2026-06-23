output "alb_dns_name" {
  description = "DNS del ALB (solo cuando create_alb = true)"
  value       = var.create_alb ? aws_lb.this[0].dns_name : null
}

output "alb_arn" {
  description = "ARN del ALB (solo cuando create_alb = true)"
  value       = var.create_alb ? aws_lb.this[0].arn : null
}

output "service_name" {
  description = "Nombre del ECS service"
  value       = aws_ecs_service.this.name
}
