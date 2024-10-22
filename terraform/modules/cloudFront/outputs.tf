output "cloudFront_domain_name" {
  value = aws_cloudfront_distribution.my_distribution.domain_name
}
output "cloudFront_oai_id" {
  value = aws_cloudfront_origin_access_identity.my_oai.id
}