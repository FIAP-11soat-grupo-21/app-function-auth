output "api_id" {
  description = "ID da API Gateway REST API"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_arn" {
  description = "ARN da API Gateway REST API"
  value       = aws_api_gateway_rest_api.main.arn
}

output "api_url" {
  description = "URL base da API Gateway"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "api_execution_arn" {
  description = "ARN de execução da API Gateway"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "stage_name" {
  description = "Nome do stage da API"
  value       = aws_api_gateway_stage.main.stage_name
}

output "deployment_id" {
  description = "ID do deployment da API"
  value       = aws_api_gateway_deployment.main.id
}

# URLs específicas dos endpoints
output "anonimo_url" {
  description = "URL completa do endpoint /anonimo"
  value       = "${aws_api_gateway_stage.main.invoke_url}/anonimo"
}

output "consultacpf_url" {
  description = "URL completa do endpoint /consultacpf"
  value       = "${aws_api_gateway_stage.main.invoke_url}/consultacpf"
}

output "registrar_url" {
  description = "URL completa do endpoint /registrar"
  value       = "${aws_api_gateway_stage.main.invoke_url}/registrar"
}

output "log_group_arn" {
  description = "ARN do grupo de logs do CloudWatch (se habilitado)"
  value       = var.enable_logging ? aws_cloudwatch_log_group.api_gateway[0].arn : null
}
