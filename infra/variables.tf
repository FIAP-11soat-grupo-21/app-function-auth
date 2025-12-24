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

variable "jwt_secret_value" {
  description = "Valor da chave JWT Secret. Se não fornecido, será gerado automaticamente"
  type        = string
  default     = null
  sensitive   = true
}

variable "lambda_environment_variables" {
  description = "Variáveis de ambiente da função Lambda"
  type        = map(string)
  default     = {}
}

variable "bucket_name" {
    description = "Nome do bucket S3 para armazenar o código da função Lambda"
    type        = string
    default     = "fiap-tc-terraform-functions-846874"
}