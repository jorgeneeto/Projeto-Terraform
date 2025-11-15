locals {
  name = "${var.environment}-frontend"
}


resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = merge(
    var.tags,
    { Name = local.name }
  )
}


resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true    # ← ACL proibida
  ignore_public_acls      = true
  block_public_policy     = false   # ← necessário para website
  restrict_public_buckets = false   # ← necessário para website
}


resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}


data "aws_iam_policy_document" "public_read" {

  statement {
    sid    = "AllowPublicRead"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.public_read.json

  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.this.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}