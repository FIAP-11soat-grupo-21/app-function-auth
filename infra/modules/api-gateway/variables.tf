variable "api_name" {
  description = "Nome da API Gateway"
  type        = string
}

variable "api_description" {
  description = "Descrição da API Gateway"
  type        = string
  default     = "API Gateway for Lambda integration"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "lambda_function_name" {
  description = "Nome da função Lambda"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "ARN de invocação da função Lambda"
  type        = string
}

variable "enable_cors" {
  description = "Habilitar CORS na API"
  type        = bool
  default     = true
}

variable "cors_allow_origins" {
  description = "Origens permitidas para CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_methods" {
  description = "Métodos HTTP permitidos para CORS"
  type        = list(string)
  default     = ["GET", "POST", "OPTIONS"]
}

variable "cors_allow_headers" {
  description = "Headers permitidos para CORS"
  type        = list(string)
  default     = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
}

variable "throttling_rate_limit" {
  description = "Limite de taxa de throttling por segundo"
  type        = number
  default     = 1000
}

variable "throttling_burst_limit" {
  description = "Limite de burst de throttling"
  type        = number
  default     = 2000
}

variable "enable_logging" {
  description = "Habilitar logging na API Gateway"
  type        = bool
  default     = true
}

variable "use_lab_role" {
  description = "Usar LabRole da AWS Academy"
  type        = bool
  default     = true
}

variable "stage_name" {
  description = "Nome do stage da API"
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}
