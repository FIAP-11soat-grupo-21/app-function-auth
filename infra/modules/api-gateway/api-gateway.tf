resource "aws_api_gateway_rest_api" "main" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    var.tags,
    {
      Name    = var.api_name
      Project = var.project_name
    }
  )
}

resource "aws_api_gateway_resource" "anonimo" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "anonimo"
}


resource "aws_api_gateway_resource" "consultacpf" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "consultacpf"
}

resource "aws_api_gateway_resource" "registrar" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "registrar"
}

resource "aws_api_gateway_method" "anonimo_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.anonimo.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "consultacpf_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.consultacpf.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "registrar_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.registrar.id
  http_method   = "POST"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "anonimo_lambda" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.anonimo.id
  http_method = aws_api_gateway_method.anonimo_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_invoke_arn
}

resource "aws_api_gateway_integration" "consultacpf_lambda" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.consultacpf.id
  http_method = aws_api_gateway_method.consultacpf_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_invoke_arn
}

resource "aws_api_gateway_integration" "registrar_lambda" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.registrar.id
  http_method = aws_api_gateway_method.registrar_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_invoke_arn
}


resource "aws_api_gateway_method" "anonimo_options" {
  count         = var.enable_cors ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.anonimo.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "consultacpf_options" {
  count         = var.enable_cors ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.consultacpf.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "registrar_options" {
  count         = var.enable_cors ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.registrar.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "anonimo_options_mock" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.anonimo.id
  http_method = aws_api_gateway_method.anonimo_options[0].http_method

  type = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration" "consultacpf_options_mock" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.consultacpf.id
  http_method = aws_api_gateway_method.consultacpf_options[0].http_method

  type = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration" "registrar_options_mock" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.registrar.id
  http_method = aws_api_gateway_method.registrar_options[0].http_method

  type = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "anonimo_options_200" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.anonimo.id
  http_method = aws_api_gateway_method.anonimo_options[0].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "consultacpf_options_200" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.consultacpf.id
  http_method = aws_api_gateway_method.consultacpf_options[0].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "registrar_options_200" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.registrar.id
  http_method = aws_api_gateway_method.registrar_options[0].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}


resource "aws_api_gateway_integration_response" "anonimo_options_integration_response" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.anonimo.id
  http_method = aws_api_gateway_method.anonimo_options[0].http_method
  status_code = aws_api_gateway_method_response.anonimo_options_200[0].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.cors_allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.cors_allow_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${join(",", var.cors_allow_origins)}'"
  }

  depends_on = [aws_api_gateway_integration.anonimo_options_mock]
}

resource "aws_api_gateway_integration_response" "consultacpf_options_integration_response" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.consultacpf.id
  http_method = aws_api_gateway_method.consultacpf_options[0].http_method
  status_code = aws_api_gateway_method_response.consultacpf_options_200[0].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.cors_allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.cors_allow_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${join(",", var.cors_allow_origins)}'"
  }

  depends_on = [aws_api_gateway_integration.consultacpf_options_mock]
}

resource "aws_api_gateway_integration_response" "registrar_options_integration_response" {
  count       = var.enable_cors ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.registrar.id
  http_method = aws_api_gateway_method.registrar_options[0].http_method
  status_code = aws_api_gateway_method_response.registrar_options_200[0].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.cors_allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.cors_allow_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${join(",", var.cors_allow_origins)}'"
  }

  depends_on = [aws_api_gateway_integration.registrar_options_mock]
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    aws_api_gateway_integration.anonimo_lambda,
    aws_api_gateway_integration.consultacpf_lambda,
    aws_api_gateway_integration.registrar_lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.anonimo.id,
      aws_api_gateway_method.anonimo_post.id,
      aws_api_gateway_integration.anonimo_lambda.id,
      aws_api_gateway_resource.consultacpf.id,
      aws_api_gateway_method.consultacpf_post.id,
      aws_api_gateway_integration.consultacpf_lambda.id,
      aws_api_gateway_resource.registrar.id,
      aws_api_gateway_method.registrar_post.id,
      aws_api_gateway_integration.registrar_lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.stage_name

  tags = merge(
    var.tags,
    {
      Name    = "${var.api_name}-${var.stage_name}"
      Project = var.project_name
    }
  )
}

resource "aws_api_gateway_method_settings" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    throttling_rate_limit  = var.throttling_rate_limit
    throttling_burst_limit = var.throttling_burst_limit
    logging_level          = var.enable_logging ? "INFO" : "OFF"
    data_trace_enabled     = var.enable_logging
    metrics_enabled        = true
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  count             = var.enable_logging ? 1 : 0
  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = 14

  tags = merge(
    var.tags,
    {
      Name    = "/aws/apigateway/${var.api_name}"
      Project = var.project_name
    }
  )
}
