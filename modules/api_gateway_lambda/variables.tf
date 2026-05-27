variable "project_name" {
  description = "Project name used for naming AWS resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment such as dev, test, or prod"
  type        = string
}

variable "lambda_source_path" {
  description = "Path to the Lambda source code file"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool used by API Gateway authorizer"
  type        = string
}