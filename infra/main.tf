module "jwt_function" {
  source = "git::https://github.com/FIAP-11soat-grupo-21/infra-core.git//modules/lambda?ref=main"

  depends_on = [module.cognito]

  api_id = data.terraform_remote_state.infra.outputs.api_gateway_id
  lambda_name = "auth-jwt-function"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.11"
  subnet_ids = data.terraform_remote_state.infra.outputs.private_subnet_id
  environment =     merge(
    var.lambda_environment_variables,
    {
      USER_POOL_ID = module.cognito.user_pool_id
      CLIENT_ID    = module.cognito.user_pool_client_id
    }
  )
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id
  memory_size = 512
  timeout     = 30

  s3_bucket = var.bucket_name
  s3_key = "lambda-function.zip"

  role_permissions = {
    cognito = {
        actions = [
            "cognito-idp:AdminInitiateAuth",
            "cognito-idp:AdminUserGlobalSignOut",
            "cognito-idp:ListUsers",
            "cognito-idp:AdminGetUser"
        ]
        resources = ["*"]
    },
    ssm = {
        actions = [
            "ssm:GetParameter",
            "ssm:GetParameters"
        ]
        resources = [
            "*"
        ]
    }
  }

  tags = data.terraform_remote_state.infra.outputs.project_common_tags
}

module "cognito" {
  source = "git::https://github.com/FIAP-11soat-grupo-21/infra-core.git//modules/cognito?ref=main"

  user_pool_name               = var.cognito_user_pool_name
  project_name                 = var.project_name
  allow_admin_create_user_only = var.allow_admin_create_user_only
  auto_verified_attributes     = var.auto_verified_attributes
  username_attributes          = var.username_attributes
  email_required               = var.email_required
  name_required                = var.name_required
  generate_secret              = var.generate_secret
  access_token_validity        = var.access_token_validity
  id_token_validity            = var.id_token_validity
  refresh_token_validity       = var.refresh_token_validity
}

resource "random_password" "jwt_secret" {
  count   = var.jwt_secret_value == null ? 1 : 0
  length  = 64
  special = true
}

resource "aws_ssm_parameter" "jwt_secret" {
  name  = "/tech-challenge/jwt-secret"
  type  = "SecureString"
  value = var.jwt_secret_value != null ? var.jwt_secret_value : random_password.jwt_secret[0].result

  tags = data.terraform_remote_state.infra.outputs.project_common_tags
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
  route_key = "POST /anonimo/{proxy+}"
  target    = "integrations/${module.jwt_function.lambda_integration_id}"
}