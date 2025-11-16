locals {
  prefix = "${var.environment}-dashboard"
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.prefix}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 6,
        height = 6,
        properties = {
          title  = "ECS CPU Utilization",
          region = var.aws_region,
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]
          ],
          period = 60,
          stat   = "Average"
        }
      },

      {
        type = "metric",
        x = 6,
        y = 0,
        width = 6,
        height = 6,
        properties = {
          title  = "ECS Memory Utilization",
          region = var.aws_region,
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]
          ],
          period = 60,
          stat   = "Average"
        }
      },

      {
        type = "metric",
        x = 0,
        y = 6,
        width = 6,
        height = 6,
        properties = {
          title  = "Lambda Invocations",
          region = var.aws_region,
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_name]
          ],
          period = 300,
          stat   = "Sum"
        }
      },

      {
        type = "metric",
        x = 6,
        y = 6,
        width = 6,
        height = 6,
        properties = {
          title  = "Lambda Errors",
          region = var.aws_region,
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_name]
          ],
          period = 300,
          stat   = "Sum"
        }
      },

      {
        type = "metric",
        x = 0,
        y = 12,
        width = 6,
        height = 6,
        properties = {
          title  = "S3 Daily Job Bucket Size",
          region = var.aws_region,
          metrics = [
            ["AWS/S3", "BucketSizeBytes", "BucketName", var.s3_dailyjob_bucket, "StorageType", "StandardStorage"]
          ],
          period = 86400,
          stat   = "Average"
        }
      }
    ]
  })
}