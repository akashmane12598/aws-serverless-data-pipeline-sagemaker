variable "project_name" {
  description = "Project name used for Glue resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name used for Glue scripts and data"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN"
  type        = string
}

variable "clean_csv_script_path" {
  description = "Local path for Glue clean CSV script"
  type        = string
}

variable "parquet_script_path" {
  description = "Local path for Glue convert to Parquet script"
  type        = string
}