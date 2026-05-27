locals {
  name_prefix = "${var.project_name}-${var.environment}"

  training_script_s3_key = "sagemaker-scripts/source.tar.gz"
}

resource "aws_s3_object" "training_script" {
  bucket = var.s3_bucket_name
  key    = local.training_script_s3_key
  source = var.training_source_archive_path
  etag   = filemd5(var.training_source_archive_path)
}

resource "aws_iam_role" "sagemaker_execution_role" {
  name = "${local.name_prefix}-sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "sagemaker_s3_policy" {
  name = "${local.name_prefix}-sagemaker-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_s3_policy_attachment" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_s3_policy.arn
}

resource "aws_sagemaker_model" "sensor_model" {
  count = var.model_artifact_url != "" ? 1 : 0

  name               = "${local.name_prefix}-sensor-model"
  execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

  primary_container {
    image          = "683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:1.2-1-cpu-py3"
    model_data_url = var.model_artifact_url

    environment = {
      SAGEMAKER_PROGRAM             = "inference.py"
      SAGEMAKER_SUBMIT_DIRECTORY    = "s3://${var.s3_bucket_name}/sagemaker-scripts/source.tar.gz"
      SAGEMAKER_REGION              = "us-east-1"
      SAGEMAKER_CONTAINER_LOG_LEVEL = "20"
    }
  }

  tags = {
    Name = "${local.name_prefix}-sensor-model"
  }
}

resource "aws_sagemaker_endpoint_configuration" "sensor_endpoint_config" {
  count = var.model_artifact_url != "" ? 1 : 0

  name = "${local.name_prefix}-sensor-endpoint-config"

  production_variants {
    variant_name           = "AllTraffic"
    model_name             = aws_sagemaker_model.sensor_model[0].name
    initial_instance_count = 1
    instance_type          = "ml.t2.medium"
  }

  tags = {
    Name = "${local.name_prefix}-sensor-endpoint-config"
  }
}

resource "aws_sagemaker_endpoint" "sensor_endpoint" {
  count = var.model_artifact_url != "" ? 1 : 0

  name                 = "${local.name_prefix}-sensor-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.sensor_endpoint_config[0].name

  tags = {
    Name = "${local.name_prefix}-sensor-endpoint"
  }
}