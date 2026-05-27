output "api_gateway_url" {
  description = "Invoke URL for the API Gateway endpoint"
  value       = module.api_gateway_lambda.api_gateway_url
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.api_gateway_lambda.lambda_function_name
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "cognito_app_client_id" {
  description = "Cognito App Client ID"
  value       = module.cognito.app_client_id
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = module.network.alb_security_group_id
}

output "ec2_security_group_id" {
  description = "EC2 Security Group ID"
  value       = module.network.ec2_security_group_id
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2_alb.ec2_instance_id
}

output "internal_alb_dns_name" {
  description = "Internal ALB DNS name"
  value       = module.ec2_alb.internal_alb_dns_name
}

output "target_group_name" {
  description = "Target group name"
  value       = module.ec2_alb.target_group_name
}

output "alb_listener_arn" {
  description = "ALB listener ARN"
  value       = module.ec2_alb.alb_listener_arn
}

output "backend_api_url" {
  description = "HTTP API Gateway URL for private ALB backend"
  value       = module.api_gateway_vpc_link.backend_api_url
}

output "vpc_link_id" {
  description = "API Gateway VPC Link ID"
  value       = module.api_gateway_vpc_link.vpc_link_id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = module.network.private_route_table_id
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.bucket_name
}

output "s3_gateway_endpoint_id" {
  description = "S3 Gateway Endpoint ID"
  value       = module.s3.s3_gateway_endpoint_id
}

output "step_function_state_machine_name" {
  description = "Step Functions state machine name"
  value       = module.step_function.state_machine_name
}

output "step_function_state_machine_arn" {
  description = "Step Functions state machine ARN"
  value       = module.step_function.state_machine_arn
}

output "s3_upload_eventbridge_rule_name" {
  description = "EventBridge rule that triggers Step Functions on raw S3 upload"
  value       = module.step_function.eventbridge_rule_name
}

output "clean_csv_glue_job_name" {
  description = "Glue job name for cleaning CSV"
  value       = module.glue.clean_csv_job_name
}

output "convert_to_parquet_glue_job_name" {
  description = "Glue job name for converting CSV to Parquet"
  value       = module.glue.convert_to_parquet_job_name
}

output "glue_role_arn" {
  description = "Glue IAM role ARN"
  value       = module.glue.glue_role_arn
}

output "sagemaker_execution_role_arn" {
  description = "SageMaker execution role ARN"
  value       = module.sagemaker.sagemaker_execution_role_arn
}

output "sagemaker_training_script_s3_uri" {
  description = "SageMaker training script S3 URI"
  value       = module.sagemaker.training_script_s3_uri
}

output "sagemaker_model_name" {
  description = "SageMaker model name"
  value       = module.sagemaker.sagemaker_model_name
}

output "sagemaker_endpoint_config_name" {
  description = "SageMaker endpoint config name"
  value       = module.sagemaker.sagemaker_endpoint_config_name
}

output "sagemaker_endpoint_name" {
  description = "SageMaker endpoint name"
  value       = module.sagemaker.sagemaker_endpoint_name
}