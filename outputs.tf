output "frontend_website_url" {
  description = "URL do website"
  value       = module.frontend.website_url
}

output "backend_cluster_name" {
  description = "Nome do ECS cluster"
  value       = module.backend.cluster_name
}

output "backend_service_name" {
  description = "Nome do ECS service"
  value       = module.backend.service_name
}

output "daily_job_bucket" {
  description = "Bucket do dailyjob"
  value       = module.daily_job.bucket_name
}

output "aws_region" {
  value = var.aws_region
}

output "sns_topic_arn" {
  value       = module.monitoring.sns_topic_arn
  description = "SNS Topic ARN para alertas"
}

output "cloudwatch_dashboard" {
  value       = module.dashboard.dashboard_name
  description = "Nome do dashboard criado"
}