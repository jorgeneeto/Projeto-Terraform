variable "environment" {
  description = "Nome do ambiente"
  type        = string
  default     = "teste"
}

variable "aws_region" {
  description = "Região padrão de deploy na AWS"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags padrão aplicadas aos recursos"
  type        = map(string)
  default = {
    Project     = "desafio-dreamsquad"
    Environment = "teste"
  }
}

variable "vpc_cidr" {
  description = "CIDR principal da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR da subnet pública"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR da subnet privada"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "backend_image" {
  description = "Imagem utilizada pelo backend"
  type        = string
  default     = "mendhak/http-https-echo"
}

variable "backend_port" {
  description = "Porta exposta pelo container"
  type        = number
  default     = 8080
}

variable "ecs_cpu" {
  description = "CPU da task Fargate"
  type        = number
  default     = 256
}

variable "ecs_memory" {
  description = "Memória da task Fargate"
  type        = number
  default     = 512
}

variable "daily_job_cron" {
  description = "Agendamento do EventBridge (UTC)"
  type        = string
  default     = "cron(0 10 * * ? *)"
}

variable "alert_email" {
  description = "Email que receberá os alertas"
  type        = string
}