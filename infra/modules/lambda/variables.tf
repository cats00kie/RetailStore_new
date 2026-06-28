variable "app_name" {
  description = "Nombre base de la app"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, test, prod)"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN del SNS topic al que la Lambda publica las alertas"
  type        = string
}

variable "log_group_names" {
  description = "Log groups de CloudWatch a monitorear"
  type        = list(string)
}

variable "aws_region" {
  description = "Region de AWS"
  type        = string
}

variable "account_id" {
  description = "ID de la cuenta AWS"
  type        = string
}
