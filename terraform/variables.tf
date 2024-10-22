variable "aws_region" {
  description = "Region"
  type        = string
}
variable "project_name" {
  description = "Project Name"
  type        = string
}
variable "domain_name" {
  description = "Route53 Domain Name"
  type        = string
}
variable "bucket_name" {
  description = "Bucket Name"
  type        = string
}
variable "cloudfront_name" {
  description = "CloudFront Name"
  type        = string
}
variable "account_id" {
  description = "Account id"
  type        = string
}
variable "certificate_id" {
  description = "Declared acm certificate id"
  type        = string
}
variable "hosted_zone_id" {
  description = "Where the record will be created in this host"
  type        = string
}

variable "aws_profile" {
  type    = string
  default = "default"
}
variable "aws_access_key" {
  type    = string
  default = "default"
}
variable "aws_secret_key" {
  type    = string
  default = "default"
}
variable "token" {
  type = string
  default = "default"
}