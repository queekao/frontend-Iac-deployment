output "s3_website_endpoint" {
  value = aws_s3_bucket.my_bucket.bucket_domain_name
}
