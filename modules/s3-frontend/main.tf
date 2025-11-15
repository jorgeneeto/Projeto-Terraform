locals {
  name = "${var.environment}-frontend"
}

# -------------------------------------------------------------
# 1. S3 BUCKET (SEM ACL, SEM OWNERSHIP CONTROLS)
# -------------------------------------------------------------
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = merge(
    var.tags,
    { Name = local.name }
  )
}

# -------------------------------------------------------------
# 2. PUBLIC ACCESS BLOCK (LIBERA APENAS POLICY)
# -------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true    # ← ACL proibida
  ignore_public_acls      = true
  block_public_policy     = false   # ← necessário para website
  restrict_public_buckets = false   # ← necessário para website
}

# -------------------------------------------------------------
# 3. WEBSITE CONFIGURATION
# -------------------------------------------------------------
resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# -------------------------------------------------------------
# 4. BUCKET POLICY PÚBLICA (ÚNICA FORMA POSSÍVEL)
# -------------------------------------------------------------
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

# -------------------------------------------------------------
# 5. UPLOAD DO INDEX (SEM ACL!)
# -------------------------------------------------------------
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.this.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}