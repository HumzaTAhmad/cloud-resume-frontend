provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "www.humza-resume.com2"
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
    domain_name              = "www.humza-resume.com2.s3.us-east-1.amazonaws.com"
    origin_id                = "www.humza-resume.com2.s3.us-east-1.amazonaws.com"
  }

  enabled             = true
  default_root_object = "index.html"



  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "www.humza-resume.com2.s3.us-east-1.amazonaws.com"


    viewer_protocol_policy = "https-only"
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
