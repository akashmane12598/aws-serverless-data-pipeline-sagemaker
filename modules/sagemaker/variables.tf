variable "project_name" {
  description = "Project name used for SageMaker resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name used for SageMaker scripts, input data, and model output"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN"
  type        = string
}

variable "training_source_archive_path" {
  description = "Local path of SageMaker training source tar.gz"
  type        = string
}

variable "model_artifact_url" {
  description = "S3 URL of the trained model artifact model.tar.gz"
  type        = string
  default     = ""
}