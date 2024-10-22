resource "aws_cloudfront_distribution" "my_distribution" {
  enabled      = true
  comment      = "This is a ${var.cloudfront_name} of cloudFront"
  price_class  = "PriceClass_200"
  http_version = "http3"
  aliases      = [var.domain_name]

  default_cache_behavior {
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized ID
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    # forwarded_values {
    #   query_string = false
    #   cookies {
    #     forward = "none"
    #   }
    # }
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  origin {
    domain_name = var.s3_website_endpoint
    origin_id   = "S3Origin"
    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.my_oai.id}"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:${var.aws_region}:${var.account_id}:certificate/${var.certificate_id}" # utilize the existing acm
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none" # Options are "none", "whitelist", or "blacklist"
      # If using "whitelist" or "blacklist", specify locations:
      # locations        = ["US", "CA"]
    }
  }
}
