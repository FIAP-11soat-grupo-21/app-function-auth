module "api_gateway" {
  source = "./modules/api-gateway"

  api_name        = "${var.project_name}-api-gateway"
  api_description = "API Gateway for Fast Food Authentication System "

  project_name    = var.project_name
  
  lambda_function_name = module.lambda.lambda_function_name
  lambda_invoke_arn    = module.lambda.lambda_function_invoke_arn
   
  enable_cors = true
  cors_allow_origins = ["*"]
  
  throttling_rate_limit  = 1000
  throttling_burst_limit = 2000

  enable_logging = true
  use_lab_role   = true

  tags = {
    Application = "API Gateway"
    UseCase     = "Fast Food Authentication API"
  }

  depends_on = [module.lambda]
}

locals {
  cognito_user_pool_id = module.cognito.user_pool_id
  lambda_function_arn  = module.lambda.lambda_function_arn
  api_base_url         = module.api_gateway.api_url
}