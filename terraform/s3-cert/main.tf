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
#-------------------------------------------S3 Bucket-----------------------------------------
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
#--------------------------------------------------AWS Certificate Manager-----------------------------------
resource "aws_acm_certificate" "godaddy_cert" {
  domain_name       = "www.humza-resume.com"
  validation_method = "DNS"


  lifecycle {
    create_before_destroy = true
  }
}