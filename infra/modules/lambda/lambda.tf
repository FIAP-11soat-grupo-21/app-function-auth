data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "aws_s3_object" "lambda_zip" {
  bucket = var.lambda_s3_bucket
  key    = var.lambda_s3_key
}

resource "aws_lambda_function" "main" {
  function_name    = var.function_name
  role            = data.aws_iam_role.lab_role.arn
  handler         = var.handler
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  s3_bucket        = var.lambda_s3_bucket
  s3_key          = var.lambda_s3_key
  source_code_hash = data.aws_s3_object.lambda_zip.etag

  layers = []

  environment {
    variables = var.environment_variables
  }

  tags = merge(
    var.tags,
    {
      Name    = var.function_name
      Project = var.project_name
    }
  )
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name    = "${var.function_name}-logs"
      Project = var.project_name
    }
  )
}