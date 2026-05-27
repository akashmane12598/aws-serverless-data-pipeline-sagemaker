variable "project_name" {
  description = "Project name used for naming EC2 and ALB resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB and EC2 will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for internal ALB and EC2"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "ec2_security_group_id" {
  description = "Security group ID for EC2 instance"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name that EC2 Spring Boot app can access"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for temporarily launching EC2 with internet access"
  type        = list(string)
}