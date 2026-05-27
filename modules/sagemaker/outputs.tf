output "sagemaker_execution_role_arn" {
  description = "IAM role ARN used by SageMaker training jobs"
  value       = aws_iam_role.sagemaker_execution_role.arn
}

output "training_script_s3_uri" {
  description = "S3 URI of the SageMaker training script"
  value       = "s3://${var.s3_bucket_name}/${local.training_script_s3_key}"
}

output "sagemaker_model_name" {
  description = "Name of the deployed SageMaker model"
  value       = var.model_artifact_url != "" ? aws_sagemaker_model.sensor_model[0].name : null
}

output "sagemaker_endpoint_config_name" {
  description = "Name of the SageMaker endpoint configuration"
  value       = var.model_artifact_url != "" ? aws_sagemaker_endpoint_configuration.sensor_endpoint_config[0].name : null
}

output "sagemaker_endpoint_name" {
  description = "Name of the SageMaker endpoint"
  value       = var.model_artifact_url != "" ? aws_sagemaker_endpoint.sensor_endpoint[0].name : null
}