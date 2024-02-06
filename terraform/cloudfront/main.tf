provider "aws" {
  region = "us-east-1"
}


terraform {
  cloud {
    organization = "humza3173"

    workspaces {
      name = "aws-portfolio-frontend"
    }
  }
}

#-----------------------------------------retrieve cert arn from tf cloud----------------------------------------
data "terraform_remote_state" "acm_cert" {
  backend = "remote"
  config = {
    organization = "humza3173"

    workspaces = {
      name = "aws-acm-cert"
    }
  }
}

#--------------------------------------------------AWS Cloudfront------------------------------------------
resource "aws_cloudfront_distribution" "s3_distribution" {

  origin {
    domain_name              = "www.humza-resume.com.s3.us-east-1.amazonaws.com"
    origin_id                = "www.humza-resume.com.s3.us-east-1.amazonaws.com"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"



  default_cache_behavior {
    compress = true
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "www.humza-resume.com.s3.us-east-1.amazonaws.com"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  aliases = ["www.humza-resume.com"]

  viewer_certificate {
    acm_certificate_arn = data.terraform_remote_state.acm_cert.outputs.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}
