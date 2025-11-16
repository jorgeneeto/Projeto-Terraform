output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "lambda_function_name" {
  value = aws_lambda_function.this.function_name
}