variable "app_name" {
  description = "Nombre de la app"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, test, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Nombre del cluster ECS"
  type        = string
}

variable "service_name" {
  description = "Nombre del servicio ECS a monitorear"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix del ALB, lo usa CloudWatch para las metricas"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN suffix del target group"
  type        = string
}

variable "alarm_email" {
  description = "Email donde llegan las alarmas. Dejar vacio para no recibir nada"
  type        = string
  default     = ""
}

variable "cpu_threshold" {
  description = "% de CPU que dispara la alarma"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "% de memoria que dispara la alarma"
  type        = number
  default     = 80
}

variable "error_5xx_threshold" {
  description = "Cuantos errores 5XX en 5 min antes de alarmar"
  type        = number
  default     = 10
}

variable "response_time_threshold" {
  description = "Tiempo de respuesta en segundos para alarmar"
  type        = number
  default     = 2
}

variable "unhealthy_hosts_threshold" {
  description = "Hosts unhealthy para disparar alarma"
  type        = number
  default     = 1
}

variable "aws_region" {
  description = "Region de AWS"
  type        = string
}
