locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_iam_role" "step_function_role" {
  name = "${local.name_prefix}-step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "step_function_logs" {
  name              = "/aws/vendedlogs/states/${local.name_prefix}-workflow"
  retention_in_days = 7
}

resource "aws_iam_policy" "step_function_logging_policy" {
  name = "${local.name_prefix}-step-function-logging-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "step_function_glue_policy" {
  name = "${local.name_prefix}-step-function-glue-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:BatchStopJobRun"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "step_function_sagemaker_policy" {
  name = "${local.name_prefix}-step-function-sagemaker-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:CreateTrainingJob",
          "sagemaker:DescribeTrainingJob",
          "sagemaker:StopTrainingJob",
          "sagemaker:AddTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = var.sagemaker_execution_role_arn
      },
      {
        Effect = "Allow"
        Action = [
          "events:PutRule",
          "events:PutTargets",
          "events:DescribeRule"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_sagemaker_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_sagemaker_policy.arn
}

resource "aws_iam_role_policy_attachment" "step_function_glue_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_glue_policy.arn
}

resource "aws_iam_role_policy_attachment" "step_function_logging_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_logging_policy.arn
}

resource "aws_sfn_state_machine" "sensor_pipeline" {
  name     = "${local.name_prefix}-sensor-pipeline"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "Sensor data pipeline workflow: S3 upload -> Glue clean CSV -> Glue convert to Parquet -> SageMaker training"
    StartAt = "ExtractS3ObjectInfo"

    States = {
      ExtractS3ObjectInfo = {
        Type = "Pass"
        Parameters = {
          "bucketName.$"      = "$.detail.bucket.name"
          "objectKey.$"       = "$.detail.object.key"
          "cleanedPrefix"     = "cleaned/"
          "parquetPrefix"     = "parquet/"
          "modelOutputPrefix" = "models/"
          "trainingJobName.$" = "States.Format('sensor-training-{}', States.UUID())"
        }
        Next = "RunCleanCsvGlueJob"
      }

      RunCleanCsvGlueJob = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = var.clean_csv_job_name
          Arguments = {
            "--S3_BUCKET.$"  = "$.bucketName"
            "--INPUT_KEY.$"  = "$.objectKey"
            "--OUTPUT_KEY.$" = "$.cleanedPrefix"
          }
        }
        ResultPath = "$.cleanCsvJobResult"
        Next       = "RunConvertToParquetGlueJob"
      }

      RunConvertToParquetGlueJob = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = var.convert_to_parquet_job_name
          Arguments = {
            "--S3_BUCKET.$"     = "$.bucketName"
            "--INPUT_PREFIX.$"  = "$.cleanedPrefix"
            "--OUTPUT_PREFIX.$" = "$.parquetPrefix"
          }
        }
        ResultPath = "$.parquetJobResult"
        Next       = "RunSageMakerTrainingJob"
      }

      RunSageMakerTrainingJob = {
        Type     = "Task"
        Resource = "arn:aws:states:::sagemaker:createTrainingJob.sync"
        Parameters = {
          "TrainingJobName.$" = "$.trainingJobName"
          RoleArn             = var.sagemaker_execution_role_arn

          AlgorithmSpecification = {
            TrainingImage     = "683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:1.2-1-cpu-py3"
            TrainingInputMode = "File"
          }

          InputDataConfig = [
            {
              ChannelName = "train"
              DataSource = {
                S3DataSource = {
                  S3DataType             = "S3Prefix"
                  "S3Uri.$"              = "States.Format('s3://{}/cleaned/', $.bucketName)"
                  S3DataDistributionType = "FullyReplicated"
                }
              }
              ContentType = "text/csv"
            }
          ]

          OutputDataConfig = {
            "S3OutputPath.$" = "States.Format('s3://{}/models/', $.bucketName)"
          }

          ResourceConfig = {
            InstanceCount  = 1
            InstanceType   = "ml.m5.large"
            VolumeSizeInGB = 10
          }

          StoppingCondition = {
            MaxRuntimeInSeconds = 600
          }

          HyperParameters = {
            "sagemaker_program"          = "train.py"
            "sagemaker_submit_directory" = var.training_script_s3_uri
            "n-estimators"               = "100"
            "test-size"                  = "0.2"
          }
        }
        ResultPath = "$.sagemakerTrainingResult"
        Next       = "WorkflowCompleted"
      }

      WorkflowCompleted = {
        Type = "Succeed"
      }
    }
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_function_logs.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  depends_on = [
    aws_iam_role_policy_attachment.step_function_logging_attach,
    aws_iam_role_policy_attachment.step_function_glue_attach,
    aws_iam_role_policy_attachment.step_function_sagemaker_attach
  ]

  tags = {
    Name = "${local.name_prefix}-sensor-pipeline"
  }
}

resource "aws_cloudwatch_event_rule" "s3_raw_upload_rule" {
  name        = "${local.name_prefix}-s3-raw-upload-rule"
  description = "Trigger Step Functions when CSV is uploaded to S3 raw folder"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [var.s3_bucket_name]
      }
      object = {
        key = [{
          prefix = "raw/"
        }]
      }
    }
  })
}

resource "aws_iam_role" "eventbridge_step_function_role" {
  name = "${local.name_prefix}-eventbridge-sfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge_start_sfn_policy" {
  name = "${local.name_prefix}-eventbridge-start-sfn-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ]
        Resource = aws_sfn_state_machine.sensor_pipeline.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_start_sfn_attach" {
  role       = aws_iam_role.eventbridge_step_function_role.name
  policy_arn = aws_iam_policy.eventbridge_start_sfn_policy.arn
}

resource "aws_cloudwatch_event_target" "s3_upload_step_function_target" {
  rule      = aws_cloudwatch_event_rule.s3_raw_upload_rule.name
  target_id = "StartSensorPipeline"
  arn       = aws_sfn_state_machine.sensor_pipeline.arn
  role_arn  = aws_iam_role.eventbridge_step_function_role.arn
}