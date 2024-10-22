# The recommendation usage is here but for simplicity I use `website` block option here
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}
resource "aws_s3_bucket_website_configuration" "my_bucket_website" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}
