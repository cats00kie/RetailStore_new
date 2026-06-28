output "alb_dns_name" {
  description = "URL publica del frontend"
  value       = "http://${module.ui.alb_dns_name}"
}

output "ecr_repository_urls" {
  description = "URLs de los repositorios ECR por servicio"
  value       = module.ecr.repository_urls
}

output "cloudwatch_dashboard" {
  description = "Nombre del dashboard de CloudWatch"
  value       = module.cloudwatch.dashboard_name
}

output "sns_topic_arn" {
  description = "ARN del topic SNS para alarmas y alertas Lambda"
  value       = module.cloudwatch.sns_topic_arn
}

output "lambda_function_name" {
  description = "Nombre de la Lambda de deteccion de errores"
  value       = module.lambda.lambda_function_name
}
