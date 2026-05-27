module "cognito" {
  source = "./modules/cognito"

  project_name = var.project_name
  environment  = var.environment
}

module "api_gateway_lambda" {
  source = "./modules/api_gateway_lambda"

  project_name       = var.project_name
  environment        = var.environment
  lambda_source_path = "${path.module}/modules/lambda/index.py"

  cognito_user_pool_arn = module.cognito.user_pool_arn
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
}

module "ec2_alb" {
  source = "./modules/ec2_alb"

  project_name = var.project_name
  environment  = var.environment

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  public_subnet_ids  = module.network.public_subnet_ids

  alb_security_group_id = module.network.alb_security_group_id
  ec2_security_group_id = module.network.ec2_security_group_id

  s3_bucket_name = module.s3.bucket_name
}

module "api_gateway_vpc_link" {
  source = "./modules/api_gateway_vpc_link"

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids    = module.network.private_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
  alb_listener_arn      = module.ec2_alb.alb_listener_arn
}

module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment

  vpc_id                 = module.network.vpc_id
  private_route_table_id = module.network.private_route_table_id
}

module "sagemaker" {
  source = "./modules/sagemaker"

  project_name = var.project_name
  environment  = var.environment

  s3_bucket_name = module.s3.bucket_name
  s3_bucket_arn  = module.s3.bucket_arn

  training_source_archive_path = "${path.module}/sagemaker-scripts/source.tar.gz"

  model_artifact_url = var.sagemaker_model_artifact_url
}

module "glue" {
  source = "./modules/glue"

  project_name = var.project_name
  environment  = var.environment

  s3_bucket_name = module.s3.bucket_name
  s3_bucket_arn  = module.s3.bucket_arn

  clean_csv_script_path = "${path.module}/glue-scripts/clean_csv_job.py"
  parquet_script_path   = "${path.module}/glue-scripts/convert_to_parquet_job.py"
}

module "step_function" {
  source = "./modules/step_function"

  project_name = var.project_name
  environment  = var.environment

  s3_bucket_name = module.s3.bucket_name
  s3_bucket_arn  = module.s3.bucket_arn

  clean_csv_job_name          = module.glue.clean_csv_job_name
  convert_to_parquet_job_name = module.glue.convert_to_parquet_job_name

  sagemaker_execution_role_arn = module.sagemaker.sagemaker_execution_role_arn
  training_script_s3_uri       = module.sagemaker.training_script_s3_uri
}