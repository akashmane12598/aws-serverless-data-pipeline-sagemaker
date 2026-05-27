variable "project_name" {
  description = "Project name used for naming Cognito resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment such as dev, test, or prod"
  type        = string
}