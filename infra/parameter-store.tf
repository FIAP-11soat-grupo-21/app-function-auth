resource "random_password" "jwt_secret" {
  count   = var.jwt_secret_value == null ? 1 : 0
  length  = 64
  special = true
}

resource "aws_ssm_parameter" "jwt_secret" {
  name  = "/tech-challenge/jwt-secret"
  type  = "SecureString"
  value = var.jwt_secret_value != null ? var.jwt_secret_value : random_password.jwt_secret[0].result

  tags = merge(
    var.tags,
    {
      Name        = "JWT Secret"
      Project     = var.project_name
      Environment = "production"
    }
  )
}
