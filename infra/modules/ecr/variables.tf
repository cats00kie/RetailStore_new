variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
}

variable "services" {
  description = "Lista de microservicios para los que crear repositorios ECR"
  type        = list(string)
  default     = ["catalog", "cart", "orders", "checkout", "ui", "admin"]
}
