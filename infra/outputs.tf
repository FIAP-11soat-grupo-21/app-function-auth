output "cognito_user_pool_id" {
  description = "ID do Cognito User Pool"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "ARN do Cognito User Pool"
  value       = module.cognito.user_pool_arn
}

output "cognito_user_pool_client_id" {
  description = "ID do Cognito User Pool Client"
  value       = module.cognito.user_pool_client_id
}

output "cognito_user_pool_client_secret" {
  description = "Secret do Cognito User Pool Client"
  value       = module.cognito.user_pool_client_secret
  sensitive   = true
}

output "lambda_function_arn" {
  description = "ARN da função Lambda"
  value       = module.lambda.lambda_function_arn
}

output "lambda_function_name" {
  description = "Nome da função Lambda"
  value       = module.lambda.lambda_function_name
}

output "lambda_function_invoke_arn" {
  description = "ARN de invocação da função Lambda"
  value       = module.lambda.lambda_function_invoke_arn
}

output "lambda_role_arn" {
  description = "ARN da role da função Lambda"
  value       = module.lambda.lambda_role_arn
}
output "api_gateway_id" {
  description = "ID da API Gateway REST API"
  value       = module.api_gateway.api_id
}

output "api_gateway_url" {
  description = "URL base da API Gateway"
  value       = module.api_gateway.api_url
}

output "api_gateway_stage_name" {
  description = "Nome do stage da API Gateway"
  value       = module.api_gateway.stage_name
}

output "endpoint_anonimo_url" {
  description = "URL completa do endpoint /anonimo"
  value       = module.api_gateway.anonimo_url
}

output "endpoint_consultacpf_url" {
  description = "URL completa do endpoint /consultacpf"
  value       = module.api_gateway.consultacpf_url
}

output "endpoint_registrar_url" {
  description = "URL completa do endpoint /registrar"
  value       = module.api_gateway.registrar_url
}
