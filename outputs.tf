output "lambda_function_name" {
  description = "The name of the Lambda Function"
  value       = aws_lambda_function.example.function_name
}

output "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.bucket.id
}
