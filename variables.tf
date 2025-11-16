variable "environment" {
  description = "Environment name"
  type        = string
  default     = "teste"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Default resource tags"
  type        = map(string)
  default = {
    Project     = "desafio-dreamsquad"
    Environment = "teste"
  }
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the main VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default     = ["10.0.2.0/24"]
}

variable "backend_image" {
  description = "Container image for backend API"
  type        = string
  default     = "mendhak/http-https-echo"
}

variable "backend_port" {
  type        = number
  description = "Listening port of backend container"
  default     = 8080
}

variable "ecs_cpu" {
  description = "Fargate CPU"
  type        = number
  default     = 256
}

variable "ecs_memory" {
  description = "Fargate Memory"
  type        = number
  default     = 512
}

variable "daily_job_cron" {
  description = "EventBridge cron expression (UTC time)"
  type        = string
  default     = "cron(03 20 * * ? *)"
}

variable "alert_email" {
  description = "Email que receberá alertas do SNS"
  type        = string
}