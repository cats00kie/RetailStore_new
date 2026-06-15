output "repository_urls" {
  description = "Mapa de servicio - URL del repositorio ECR"
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}
