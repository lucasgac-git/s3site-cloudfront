resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket

  tags = {
    Name = var.name_tag
    Env  = var.env_tag
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}


resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket     = aws_s3_bucket.s3_bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "object" {
  bucket       = aws_s3_bucket.s3_bucket.id
  key          = "index.html"
  source       = var.local_source
  content_type = "text/html"
  depends_on   = [aws_s3_bucket.s3_bucket]
}