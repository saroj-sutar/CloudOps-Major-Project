output "s3_bucket_name" {
  description = "Name of the CloudOps S3 bucket"
  value       = aws_s3_bucket.cloudops_storage.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the CloudOps S3 bucket"
  value       = aws_s3_bucket.cloudops_storage.arn
}
