resource "aws_s3_bucket" "web" {
  bucket        = "easy-thank-you-notes-web"
  force_destroy = "true"
}

resource "aws_s3_bucket_website_configuration" "web" {
  bucket = "easy-thank-you-notes-web"

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_acl" "web-acl" {
  bucket = aws_s3_bucket.web.id
  acl    = "public-read"
}

locals {
  s3_origin_id = "only-origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.web.website_endpoint
    origin_id   = local.s3_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }


  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["www.easythankyounotes.com"]

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn            = "arn:aws:acm:us-east-1:836386213271:certificate/ec33ea96-3b71-4c7f-bd97-06b56b7b4579"
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }
}

resource "aws_route53_record" "web_alias" {
  zone_id = var.hosted_zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
