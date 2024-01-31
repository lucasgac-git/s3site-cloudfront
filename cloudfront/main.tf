data "aws_s3_bucket" "selectedPrimary" {
  bucket = var.s3_primary
}
data "aws_s3_bucket" "selectedFailover" {
  bucket = var.s3_failover
}

resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
  name                              = "Cloudfront S3 OAC"
  description                       = "Cloudfront S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  
}


resource "aws_cloudfront_distribution" "s3_distribution" {

  origin_group {
    origin_id = "distribution"
    member {
      origin_id = "s3Primary"
    }
    member {
      origin_id = "s3Failover"
    }
    failover_criteria {
      status_codes = [403, 404, 500, 502, 503, 504]
    }
  }


  origin {
    domain_name              = data.aws_s3_bucket.selectedPrimary.bucket_regional_domain_name
    origin_id                = "s3Primary"
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
  }

  aliases = ["testsite.website.net"]
  default_root_object = "index.html"

  origin {
    domain_name              = data.aws_s3_bucket.selectedPrimary.bucket_regional_domain_name
    origin_id                = "s3Failover"
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
  }

  enabled = true
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "distribution"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "allow-all"

  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["BR", "US"]
    }
  }


  tags = {
    Env = "TEST"
  }

  viewer_certificate {
    # cloudfront_default_certificate = true
    acm_certificate_arn =  ""
    ssl_support_method = "sni-only"
  }

}