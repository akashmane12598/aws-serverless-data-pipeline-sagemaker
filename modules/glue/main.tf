locals {
  name_prefix = "${var.project_name}-${var.environment}"

  clean_script_s3_key   = "glue-scripts/clean_csv_job.py"
  parquet_script_s3_key = "glue-scripts/convert_to_parquet_job.py"
}

resource "aws_s3_object" "clean_csv_script" {
  bucket = var.s3_bucket_name
  key    = local.clean_script_s3_key
  source = var.clean_csv_script_path
  etag   = filemd5(var.clean_csv_script_path)
}

resource "aws_s3_object" "parquet_script" {
  bucket = var.s3_bucket_name
  key    = local.parquet_script_s3_key
  source = var.parquet_script_path
  etag   = filemd5(var.parquet_script_path)
}

resource "aws_iam_role" "glue_role" {
  name = "${local.name_prefix}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "glue_s3_policy" {
  name = "${local.name_prefix}-glue-s3-policy"

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
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_s3_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "glue_service_role_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_job" "clean_csv_job" {
  name     = "${local.name_prefix}-clean-csv-job"
  role_arn = aws_iam_role.glue_role.arn

  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 10

  command {
    name            = "glueetl"
    script_location = "s3://${var.s3_bucket_name}/${local.clean_script_s3_key}"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
    "--S3_BUCKET"                        = var.s3_bucket_name
    "--INPUT_KEY"                        = "raw/sensor-data.csv"
    "--OUTPUT_KEY"                       = "cleaned/"
  }

  depends_on = [
    aws_s3_object.clean_csv_script,
    aws_iam_role_policy_attachment.glue_s3_policy_attachment,
    aws_iam_role_policy_attachment.glue_service_role_attachment
  ]
}

resource "aws_glue_job" "convert_to_parquet_job" {
  name     = "${local.name_prefix}-convert-to-parquet-job"
  role_arn = aws_iam_role.glue_role.arn

  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 10

  command {
    name            = "glueetl"
    script_location = "s3://${var.s3_bucket_name}/${local.parquet_script_s3_key}"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
    "--S3_BUCKET"                        = var.s3_bucket_name
    "--INPUT_PREFIX"                     = "cleaned/"
    "--OUTPUT_PREFIX"                    = "parquet/"
  }

  depends_on = [
    aws_s3_object.parquet_script,
    aws_iam_role_policy_attachment.glue_s3_policy_attachment,
    aws_iam_role_policy_attachment.glue_service_role_attachment
  ]
}