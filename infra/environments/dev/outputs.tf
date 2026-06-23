output "alb_dns_name" {
  description = "URL publica del frontend"
  value       = "http://${module.ui.alb_dns_name}"
}

output "ecr_repository_urls" {
  description = "URLs de los repositorios ECR por servicio"
  value       = module.ecr.repository_urls
}
