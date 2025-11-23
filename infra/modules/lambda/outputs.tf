output "lambda_function_arn" {
  description = "ARN da função Lambda"
  value       = aws_lambda_function.main.arn
}

output "lambda_function_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.main.function_name
}

output "lambda_function_invoke_arn" {
  description = "ARN de invocação da função Lambda"
  value       = aws_lambda_function.main.invoke_arn
}

output "lambda_role_arn" {
  description = "ARN da LabRole utilizada"
  value       = data.aws_iam_role.lab_role.arn
}

output "cloudwatch_log_group_name" {
  description = "Nome do grupo de logs do CloudWatch"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}
