resource "aws_route53_record" "alias_cloudfront_record" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = var.cloudFront_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # The fixed HostedZoneId for CloudFront
    evaluate_target_health = true
  }
}
