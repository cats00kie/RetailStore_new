output "lambda_function_name" {
  description = "Nombre de la Lambda de deteccion de errores"
  value       = aws_lambda_function.error_detector.function_name
}

output "lambda_function_arn" {
  description = "ARN de la Lambda"
  value       = aws_lambda_function.error_detector.arn
}
