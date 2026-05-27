output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.data_bucket.bucket
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.data_bucket.arn
}

output "s3_gateway_endpoint_id" {
  description = "S3 VPC Gateway Endpoint ID"
  value       = aws_vpc_endpoint.s3_gateway_endpoint.id
}