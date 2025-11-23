module "cognito" {
  source = "./modules/cognito"

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

  tags = var.tags
}
