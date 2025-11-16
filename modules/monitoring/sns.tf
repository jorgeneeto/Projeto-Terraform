locals {
  prefix = "${var.environment}-monitoring"
}

# SNS Topic para alertas
resource "aws_sns_topic" "alerts" {
  name = var.alerts_topic_name != "" ? var.alerts_topic_name : "${var.environment}-alerts"
}

# Assinatura por email
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}