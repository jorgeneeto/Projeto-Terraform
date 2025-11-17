locals {
  prefix = "${var.environment}-dailyjob"

  lambda_code = <<EOF
import boto3
from datetime import datetime

def handler(event, context):
    now = datetime.utcnow().strftime("%Y-%m-%d_%H-%M-%S")
    filename = f"{now}.txt"
    boto3.client("s3").put_object(
        Bucket="${var.bucket_name}",
        Key=filename,
        Body=f"Arquivo gerado em {now} UTC"
    )
    return {"status": "ok", "file": filename}
EOF
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "clean-old-versions"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  rule {
    id     = "abort-multipart"
    status = "Enabled"

    filter {
      prefix = ""
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "lambda_role" {
  name = "${local.prefix}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${local.prefix}-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:*"],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    content  = local.lambda_code
    filename = "lambda.py"
  }
}

resource "aws_lambda_function" "this" {
  function_name    = "${local.prefix}-function"
  handler          = "lambda.handler"
  runtime          = "python3.10"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 10
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  tags             = var.tags
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${local.prefix}-rule"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "dailyjob"
  arn       = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "eventbridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
