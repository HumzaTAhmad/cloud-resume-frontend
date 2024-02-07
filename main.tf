provider "aws" {
  region = "us-east-1"
}


terraform {
  cloud {
    organization = "humza3173"

    workspaces {
      tags = ["prod", "test"]
    }
  }
}

#------------------------------------------dev domain name----------------------------------
variable "domain_name" {
  description = "The name of the S3 bucket"
  type        = string
}


#-------------------------------------------S3 Bucket-----------------------------------------
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.domain_name
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }
}

data "aws_iam_policy_document" "allow_public_read_access_to_bucket" {
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.my_bucket.bucket}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_public_read_access_to_bucket" {
  depends_on = [
      data.aws_iam_policy_document.allow_public_read_access_to_bucket,
      aws_s3_bucket.my_bucket
  ]
  bucket = aws_s3_bucket.my_bucket.id
  policy = data.aws_iam_policy_document.allow_public_read_access_to_bucket.json
}

#--------------------------------------------------AWS Certificate Manager-----------------------------------
resource "aws_acm_certificate" "godaddy_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"


  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------AWS Cloudfront------------------------------------------
resource "aws_cloudfront_distribution" "s3_distribution" {

  origin {
    domain_name              = "${var.domain_name}.s3.us-east-1.amazonaws.com"
    origin_id                = "${var.domain_name}.s3.us-east-1.amazonaws.com"

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
    target_origin_id = "${var.domain_name}.s3.us-east-1.amazonaws.com"

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

  aliases = [var.domain_name]

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.godaddy_cert.arn
    ssl_support_method  = "sni-only"
  }
}
