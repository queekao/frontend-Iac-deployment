resource "aws_cloudfront_origin_access_identity" "my_oai" {
  comment = "This is a ${var.cloudfront_name} of cloudFront OAI"
}
