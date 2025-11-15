locals {
  prefix = "${var.environment}-dailyjob"
}

#
# Bucket onde o job armazena os arquivos
#
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = merge(var.tags, {
    Name = "${local.prefix}-bucket"
  })
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#
# IAM Role da Lambda
#
resource "aws_iam_role" "lambda_role" {
  name = "${local.prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Permissão mínima para escrever no bucket
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${local.prefix}-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = ["s3:PutObject"],
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}

#
# Lambda Function
#
resource "aws_lambda_function" "this" {
  function_name = "${local.prefix}-function"
  handler       = "lambda.handler"
  runtime       = "python3.10"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 10

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = merge(var.tags, {
    Name = "${local.prefix}-lambda"
  })
}

#
# Empacota o lambda.py em um ZIP automaticamente
#
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"
  source {
    content  = templatefile("${path.module}/lambda.py", { bucket = var.bucket_name })
    filename = "lambda.py"
  }
}

#
# EventBridge Rule (agendamento)
#
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${local.prefix}-rule"
  schedule_expression = var.schedule_expression

  tags = merge(var.tags, {
    Name = "${local.prefix}-rule"
  })
}

#
# EventBridge Target → Lambda
#
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "dailyjob"
  arn       = aws_lambda_function.this.arn
}

#
# Permissão para EventBridge invocar a Lambda
#
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
