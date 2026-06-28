variable "aws_region" {
  description = "Región para desplegar la infra"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de despliegue, por ejemplo: dev, test, prod"
  type        = string
}

variable "vpc_cidr_block" {
  description = "El bloque CIDR para la VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "Los bloques CIDR para las subredes publicas"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "Los bloques CIDR para las subredes privadas"
  type        = list(string)
}

variable "vpc_name" {
  description = "El nombre de la VPC"
  type        = string
}

variable "azs" {
  description = "Las zonas de disponibilidad para la VPC"
  type        = list(string)
}

variable "cluster_name" {
  description = "El nombre del cluster de ECS"
  type        = string
}

variable "app_cpu" {
  description = "CPU para la tarea Fargate (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512
}

variable "app_memory" {
  description = "Memoria para la tarea Fargate en MB"
  type        = number
  default     = 1024
}

variable "app_desired_count" {
  description = "Número de tareas deseadas"
  type        = number
  default     = 1
}

variable "orders_db_password" {
  description = "Password para la base de datos de orders"
  type        = string
  sensitive   = true
}

variable "catalog_db_password" {
  description = "Password para la base de datos de catalog"
  type        = string
  sensitive   = true
}
