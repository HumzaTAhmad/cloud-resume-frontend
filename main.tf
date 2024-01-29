provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "www.humza-resume.com"
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

resource "aws_s3_bucket_policy" "allow_public_read_access_to_bucket" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = data.aws_iam_policy_document.allow_public_read_access_to_bucket.json
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

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized policy ID
    origin_request_policy_id = "216adef4-5c84-46e2-86d3-4a556efcd453" # Managed-AllViewer policy ID
    viewer_protocol_policy = "redirect-to-https"

  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  aliases = ["www.humza-resume.com"]

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:654654379379:certificate/26836a5e-4d8e-4cbc-bf18-eb7d9cb8f35a"
    ssl_support_method  = "sni-only"
  }
}
