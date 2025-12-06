variable "function_name" {
  description = "Nome da função Lambda"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "lambda_s3_bucket" {
  description = "Bucket S3 para armazenar o código da Lambda"
  type        = string
}

variable "lambda_s3_key" {
  description = "Chave S3 do arquivo ZIP da Lambda"
  type        = string
}

variable "handler" {
  description = "Handler da função Lambda"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "runtime" {
  description = "Runtime da função Lambda"
  type        = string
  default     = "python3.11"
}

variable "timeout" {
  description = "Timeout da função Lambda em segundos"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Memória da função Lambda em MB"
  type        = number
  default     = 256
}

variable "environment_variables" {
  description = "Variáveis de ambiente da função Lambda"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs do CloudWatch"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}

