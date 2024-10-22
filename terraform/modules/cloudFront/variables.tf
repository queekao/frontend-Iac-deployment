variable "cloudfront_name" {
  description = "CloudFront Name"
  type        = string
}

variable "account_id" {
  description = "Account id"
  type        = string
}
variable "certificate_id" {
  description = "Certificate id"
  type        = string
}

variable "domain_name" {
  description = "Route53 Domain Name"
  type        = string
}
variable "s3_website_endpoint" {
  description = "s3 website endpoint"
  type        = string
}
variable "aws_region" {
  description = "region"
  type        = string
}
