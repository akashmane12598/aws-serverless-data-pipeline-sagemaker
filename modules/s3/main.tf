locals {
  bucket_name = lower("${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}-data")
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "data_bucket" {
  bucket = local.bucket_name

  tags = {
    Name        = local.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "data_bucket_block" {
  bucket = aws_s3_bucket.data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "data_bucket_versioning" {
  bucket = aws_s3_bucket.data_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "raw_folder" {
  bucket  = aws_s3_bucket.data_bucket.id
  key     = "raw/"
  content = ""
}

resource "aws_s3_object" "cleaned_folder" {
  bucket  = aws_s3_bucket.data_bucket.id
  key     = "cleaned/"
  content = ""
}

resource "aws_s3_object" "parquet_folder" {
  bucket  = aws_s3_bucket.data_bucket.id
  key     = "parquet/"
  content = ""
}

resource "aws_s3_object" "models_folder" {
  bucket  = aws_s3_bucket.data_bucket.id
  key     = "models/"
  content = ""
}

resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    var.private_route_table_id
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-s3-gateway-endpoint"
  }
}

resource "aws_s3_bucket_notification" "eventbridge_notification" {
  bucket      = aws_s3_bucket.data_bucket.id
  eventbridge = true
}