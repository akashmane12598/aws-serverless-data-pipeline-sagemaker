output "glue_role_arn" {
  description = "IAM role ARN used by Glue jobs"
  value       = aws_iam_role.glue_role.arn
}

output "clean_csv_job_name" {
  description = "Name of the Glue job that cleans CSV"
  value       = aws_glue_job.clean_csv_job.name
}

output "convert_to_parquet_job_name" {
  description = "Name of the Glue job that converts cleaned CSV to Parquet"
  value       = aws_glue_job.convert_to_parquet_job.name
}