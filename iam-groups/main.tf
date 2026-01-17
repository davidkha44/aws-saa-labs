# Buckets
resource "aws_s3_bucket" "catpics" {
  bucket = "my-cat-pictures-bucket-123456"
}

resource "aws_s3_bucket" "dogpics" {
  bucket = "my-dog-pictures-bucket-123456"
}

resource "aws_s3_bucket" "animalpics" {
  bucket = "my-animal-pictures-bucket-123456"
}

# IAM User Login Profile
resource "aws_iam_user" "sally" {
  name = "sally"
}

resource "aws_iam_user_login_profile" "sally_login" {
  user                    = aws_iam_user.sally.name
  password_reset_required = true
}

resource "aws_iam_policy" "allow_all_s3_except_cats" {
  name        = "AllowAllS3ExceptCats"
  description = "Allow access to all S3 buckets, except catpics"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "*"
      },
      {
        Effect   = "Deny",
        Action   = "s3:*",
        Resource = [aws_s3_bucket.catpics.arn, "${aws_s3_bucket.catpics.arn}/*"]
      }
    ]
  })
}

resource "aws_iam_group" "dev" {
  name = "dev"
}

resource "aws_iam_group_policy_attachment" "dev_attach_policy" {
  group      = aws_iam_group.dev.name
  policy_arn = aws_iam_policy.allow_all_s3_except_cats.arn
}

resource "aws_iam_user_group_membership" "sally_in_dev" {
  user = aws_iam_user.sally.name
  groups = [
    aws_iam_group.dev.name
  ]
}

resource "aws_iam_user_policy_attachment" "sally_change_password" {
  user       = aws_iam_user.sally.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

output "sally_initial_password" {
  value     = aws_iam_user_login_profile.sally_login.password
  sensitive = true
}
