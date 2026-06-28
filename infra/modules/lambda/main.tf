data "aws_iam_role" "labrole" {
  name = "LabRole"
}

# Zipea el codigo Python para subirlo a Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/function.zip"
  source_file = "${path.module}/function/index.py"
}

# Log group propio de la Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.app_name}-error-detector-${var.environment}"
  retention_in_days = 7

  tags = {
    environment = var.environment
  }
}

resource "aws_lambda_function" "error_detector" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.app_name}-error-detector-${var.environment}"
  role             = data.aws_iam_role.labrole.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]

  tags = {
    environment = var.environment
  }
}

# Permiso para que CloudWatch Logs pueda invocar la Lambda
resource "aws_lambda_permission" "allow_cloudwatch_logs" {
  for_each = toset(var.log_group_names)

  statement_id  = "AllowCWLogs-${replace(replace(each.value, "/", "-"), ".", "-")}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.error_detector.function_name
  principal     = "logs.amazonaws.com"
  source_arn    = "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:${each.value}:*"
}

# Subscription filter: dispara la Lambda cuando aparece ERROR en los logs
resource "aws_cloudwatch_log_subscription_filter" "error_filter" {
  for_each = toset(var.log_group_names)

  name            = "${var.app_name}-errors-${replace(replace(each.value, "/", "-"), ".", "-")}"
  log_group_name  = each.value
  filter_pattern  = "?ERROR ?FATAL ?panic ?EXCEPTION"
  destination_arn = aws_lambda_function.error_detector.arn

  depends_on = [aws_lambda_permission.allow_cloudwatch_logs]
}
