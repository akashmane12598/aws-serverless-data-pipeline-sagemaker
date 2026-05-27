output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.sensor_pipeline.arn
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.sensor_pipeline.name
}

output "eventbridge_rule_name" {
  description = "EventBridge rule name for S3 raw upload trigger"
  value       = aws_cloudwatch_event_rule.s3_raw_upload_rule.name
}