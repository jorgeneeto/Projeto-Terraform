output "sns_topic_arn" {
  description = "ARN do SNS Topic"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "Nome do SNS Topic"
  value       = aws_sns_topic.alerts.name
}