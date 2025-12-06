variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "cognito_user_pool_name" {
  description = "Nome do Cognito User Pool"
  type        = string
  default     = "tech-challenge-user-pool"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "tech-challenge"
}

variable "allow_admin_create_user_only" {
  description = "Permitir apenas criação de usuário por admin"
  type        = bool
  default     = false
}

variable "auto_verified_attributes" {
  description = "Atributos auto verificados"
  type        = list(string)
  default     = ["email"]
}

variable "username_attributes" {
  description = "Atributos usados como username"
  type        = list(string)
  default     = []
}

variable "email_required" {
  description = "E-mail é requerido"
  type        = bool
  default     = true
}

variable "name_required" {
  description = "Nome é requerido"
  type        = bool
  default     = true
}

variable "generate_secret" {
  description = "Gerar secret para o client"
  type        = bool
  default     = true
}

variable "access_token_validity" {
  description = "Validade do access token em minutos"
  type        = number
  default     = 60
}

variable "id_token_validity" {
  description = "Validade do id token em minutos"
  type        = number
  default     = 60
}

variable "refresh_token_validity" {
  description = "Validade do refresh token em dias"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags adicionais"
  type        = map(string)
  default = {
    Environment = "development"
    ManagedBy   = "terraform"
  }
}

# Variáveis para o módulo Lambda
variable "lambda_function_name" {
  description = "Nome da função Lambda"
  type        = string
  default     = "tech-challenge-lambda"
}


variable "lambda_handler" {
  description = "Handler da função Lambda"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Runtime da função Lambda"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Timeout da função Lambda em segundos"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Memória da função Lambda em MB"
  type        = number
  default     = 256
}

variable "lambda_environment_variables" {
  description = "Variáveis de ambiente da função Lambda"
  type        = map(string)
  default     = {}
}

variable "lambda_log_retention_days" {
  description = "Dias de retenção dos logs do CloudWatch"
  type        = number
  default     = 14
}

variable "lambda_s3_bucket" {
  description = "Bucket S3 para armazenar o código da Lambda"
  type        = string
}

variable "lambda_s3_key" {
  description = "Chave S3 do arquivo ZIP da Lambda"
  type        = string
  default     = "lambda-function.zip"
}

# Variável para JWT Secret
variable "jwt_secret_value" {
  description = "Valor da chave JWT Secret. Se não fornecido, será gerado automaticamente"
  type        = string
  default     = null
  sensitive   = true
}
