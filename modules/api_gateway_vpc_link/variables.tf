variable "project_name" {
  description = "Project name used for naming API Gateway VPC Link resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where API Gateway VPC Link ENIs will be created"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID used by the VPC Link"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of the internal ALB listener"
  type        = string
}