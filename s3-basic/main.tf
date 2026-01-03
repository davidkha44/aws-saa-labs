resource "aws_s3_bucket" "koalacampaign" {
  bucket = "koalacampaign-bucket-123456"
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.koalacampaign.id

  # Setting these to false turns OFF the protection
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "batch_images" {
  for_each = fileset("${path.module}/assets/", "*")

  bucket       = aws_s3_bucket.koalacampaign.id
  key          = "assets/${each.value}"
  source       = "${path.module}/assets/${each.value}"
  etag         = filemd5("${path.module}/assets/${each.value}")
  content_type = "image/jpeg"
}

resource "aws_s3_bucket_policy" "public_image_access" {
  bucket = aws_s3_bucket.koalacampaign.id

  # This ensures the 'Block Public Access' is turned OFF before 
  # applying the policy, otherwise AWS will reject this.
  depends_on = [aws_s3_bucket_public_access_block.public_access]

  policy = jsonencode({
    Version = "2026-01-03"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*" # This means 'Everyone'
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.koalacampaign.arn}/*" # This applies to all files in the bucket
      }
    ]
  })
}
