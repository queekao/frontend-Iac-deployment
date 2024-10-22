module "cloudFront" {
  source              = "./modules/cloudFront"
  cloudfront_name     = var.cloudfront_name
  account_id          = var.account_id
  certificate_id      = var.certificate_id
  domain_name         = var.domain_name
  aws_region          = var.aws_region
  s3_website_endpoint = module.s3.s3_website_endpoint
}

module "route53" {
  source                 = "./modules/route53"
  cloudFront_domain_name = module.cloudFront.cloudFront_domain_name
  hosted_zone_id         = var.hosted_zone_id
  domain_name            = var.domain_name
}

module "s3" {
  source            = "./modules/s3"
  cloudFront_oai_id = module.cloudFront.cloudFront_oai_id
  bucket_name       = var.bucket_name
}


