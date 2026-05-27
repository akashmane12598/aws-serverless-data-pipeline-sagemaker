output "api_gateway_url" {
  description = "Invoke URL for the API Gateway hello endpoint"
  value       = "${aws_api_gateway_stage.dev_stage.invoke_url}/hello"
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.hello_lambda.function_name
}

output "api_gateway_name" {
  description = "API Gateway name"
  value       = aws_api_gateway_rest_api.api.name
}