variable "environment" {
  type = string
}

variable "alert_email" {
  type        = string
  description = "Email que receberá alertas"
}

variable "alerts_topic_name" {
  type        = string
  default     = ""
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "lambda_function_name" {
  type = string
}