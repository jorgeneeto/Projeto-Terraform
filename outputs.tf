output "frontend_website_url" {
  description = "URL of static website"
  value       = module.frontend.website_url
}

output "backend_cluster_name" {
  description = "Name of ECS cluster"
  value       = module.backend.cluster_name
}

output "backend_service_name" {
  description = "Name of ECS service"
  value       = module.backend.service_name
}

output "daily_job_bucket" {
  description = "Bucket where Lambda stores daily files"
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