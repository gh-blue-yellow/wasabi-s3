resource "aws_s3_bucket" "buckets" {
  for_each = toset(var.bucket_names)
  bucket   = each.key
}

resource "aws_s3_bucket_public_access_block" "bucket_block_public_access" {
  for_each                = toset(var.bucket_names)
  bucket                  = each.key
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  for_each = toset(var.bucket_names)
  bucket   = each.key
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  for_each      = toset(var.bucket_names)
  bucket        = each.key
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

resource "aws_kms_key" "encryption_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption_config" {
  for_each = toset(var.bucket_names)
  bucket   = each.key
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_iam_user" "users" {
  for_each = toset(var.user_names)
  name     = each.key
}

resource "aws_iam_policy" "readonly_policy" {
  for_each = toset(var.bucket_names)
  name     = "${each.key}-readonly-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["s3:GetObject", "s3:ListBucket"]
      Effect = "Allow"
      Resource = [
        "arn:aws:s3:::${each.key}",
        "arn:aws:s3:::${each.key}/*"
      ]
    }]
  })
}

resource "aws_iam_policy" "readwrite_policy" {
  for_each = toset(var.bucket_names)
  name     = "${each.key}-readwrite-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:ReplicateObject",
        "s3:RestoreObject",
        "s3:PutObjectAcl",
        "s3:DeleteObjectVersion",
        "s3:PutObjectVersionAcl",
        "s3:GetObjectVersion",
        "s3:GetObjectAcl",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging",
        "s3:DeleteObjectTagging"
      ]
      Effect = "Allow"
      Resource = [
        "arn:aws:s3:::${each.key}",
        "arn:aws:s3:::${each.key}/*"
      ]
    }]
  })
}

resource "aws_iam_user_policy_attachment" "user_policies" {
  for_each   = var.user_policy_attachments
  user       = each.key
  policy_arn = each.value
}

output "readonly_policy_arns" {
  value = { for k, v in aws_iam_policy.readonly_policy : k => v.arn }
}

output "readwrite_policy_arns" {
  value = { for k, v in aws_iam_policy.readwrite_policy : k => v.arn }
}
