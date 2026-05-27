output "backend_api_url" {
  description = "HTTP API Gateway URL for private backend"
  value       = "${aws_apigatewayv2_api.backend_http_api.api_endpoint}/backend"
}

output "vpc_link_id" {
  description = "API Gateway VPC Link ID"
  value       = aws_apigatewayv2_vpc_link.backend_vpc_link.id
}

output "backend_http_api_id" {
  description = "HTTP API ID"
  value       = aws_apigatewayv2_api.backend_http_api.id
}