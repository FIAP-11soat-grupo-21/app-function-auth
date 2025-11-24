module "lambda" {
  source             = "./modules/lambda"
  function_name      = var.lambda_function_name
  project_name       = var.project_name
  lambda_s3_bucket   = var.lambda_s3_bucket
  lambda_s3_key      = var.lambda_s3_key
  handler            = var.lambda_handler
  runtime            = var.lambda_runtime
  timeout            = var.lambda_timeout
  memory_size        = var.lambda_memory_size
  log_retention_days = var.lambda_log_retention_days
  environment_variables = merge(
    var.lambda_environment_variables,
    {
      USER_POOL_ID = module.cognito.user_pool_id
      CLIENT_ID    = module.cognito.user_pool_client_id
    }
  )

  tags       = var.tags
  depends_on = [module.cognito]
}
