locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_apigatewayv2_api" "backend_http_api" {
  name          = "${local.name_prefix}-backend-http-api"
  protocol_type = "HTTP"

  tags = {
    Name = "${local.name_prefix}-backend-http-api"
  }
}

resource "aws_apigatewayv2_vpc_link" "backend_vpc_link" {
  name = "${local.name_prefix}-vpc-link"

  subnet_ids = var.private_subnet_ids

  security_group_ids = [
    var.alb_security_group_id
  ]

  tags = {
    Name = "${local.name_prefix}-vpc-link"
  }
}

resource "aws_apigatewayv2_integration" "alb_integration" {
  api_id = aws_apigatewayv2_api.backend_http_api.id

  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"

  connection_type = "VPC_LINK"
  connection_id   = aws_apigatewayv2_vpc_link.backend_vpc_link.id

  integration_uri = var.alb_listener_arn

  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "backend_route" {
  api_id = aws_apigatewayv2_api.backend_http_api.id

  route_key = "ANY /backend/{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

resource "aws_apigatewayv2_route" "backend_root_route" {
  api_id = aws_apigatewayv2_api.backend_http_api.id

  route_key = "ANY /backend"

  target = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id = aws_apigatewayv2_api.backend_http_api.id

  name        = "$default"
  auto_deploy = true

  tags = {
    Name = "${local.name_prefix}-backend-stage"
  }
}