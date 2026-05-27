variable "project_name" {
  description = "Project name used for Step Functions resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name that triggers the workflow"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN"
  type        = string
}

variable "clean_csv_job_name" {
  description = "Name of the Glue job that cleans the raw CSV file"
  type        = string
}

variable "convert_to_parquet_job_name" {
  description = "Name of the Glue job that converts cleaned CSV to Parquet"
  type        = string
}

variable "sagemaker_execution_role_arn" {
  description = "SageMaker execution role ARN"
  type        = string
}

variable "training_script_s3_uri" {
  description = "S3 URI of SageMaker training script"
  type        = string
}