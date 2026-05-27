output "ec2_instance_id" {
  description = "ID of the EC2 instance running backend app"
  value       = aws_instance.springboot_ec2.id
}

output "internal_alb_dns_name" {
  description = "DNS name of the internal Application Load Balancer"
  value       = aws_lb.internal_alb.dns_name
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.springboot_tg.arn
}

output "target_group_name" {
  description = "Target group name"
  value       = aws_lb_target_group.springboot_tg.name
}

output "alb_listener_arn" {
  description = "ARN of the ALB HTTP listener"
  value       = aws_lb_listener.http_listener.arn
}

output "internal_alb_arn" {
  description = "ARN of the internal ALB"
  value       = aws_lb.internal_alb.arn
}