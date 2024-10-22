resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = jsonencode({
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${var.cloudFront_oai_id}" }
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
    }]
  })
  # Ignores changes in policy of s3 because terraform can't detect jsonencode if the string is the same or not
  lifecycle {
    ignore_changes = [
      policy,
    ]
  }
}
