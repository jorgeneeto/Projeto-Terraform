output "cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "Name of the ECS Service"
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "Task Definition ARN"
  value       = aws_ecs_task_definition.this.arn
}

output "security_group_id" {
  description = "Security Group ID used by the backend"
  value       = aws_security_group.sg.id
}

output "log_group_name" {
  description = "CloudWatch Log Group used by ECS"
  value       = aws_cloudwatch_log_group.this.name
}