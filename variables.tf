variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for naming AWS resources"
  type        = string
  default     = "aws-sensor-project"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "sagemaker_model_artifact_url" {
  description = "S3 URL of the trained SageMaker model artifact model.tar.gz"
  type        = string
  default     = ""
}