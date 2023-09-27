provider "aws" {
  region  = "us-west-2"
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


resource "aws_lambda_function" "example" {
  function_name    = "lambda_function_name"
  s3_bucket        = aws_s3_bucket.bucket.bucket
  s3_key           = "lambda_function_payload.zip"
  handler          = "helloworld.lambda_handler"
  runtime          = "python3.8"
  role             = aws_iam_role.role.arn

  depends_on = [
    aws_s3_bucket_object.object,
  ]
}

data "archive_file" "example_zip" {
  type        = "zip"
  source_dir  = "lambda_function"
  output_path = "lambda_function_payload.zip"
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "lambda_function_payload.zip"
  source = "lambda_function_payload.zip" 

  depends_on = [
    data.archive_file.example_zip,
  ]
}

resource "aws_iam_role" "role" {
  name = "lambda_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
