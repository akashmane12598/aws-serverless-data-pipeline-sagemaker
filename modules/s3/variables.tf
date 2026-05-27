variable "project_name" {
  description = "Project name used for S3 bucket naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for S3 gateway endpoint"
  type        = string
}

variable "private_route_table_id" {
  description = "Private route table ID for S3 gateway endpoint"
  type        = string
}