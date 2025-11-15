variable "environment" {
  type = string
}

variable "schedule_expression" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "tags" {
  type = map(string)
}