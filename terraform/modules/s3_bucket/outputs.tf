output "bucket_ids" {
  value = aws_s3_bucket.buckets.*.id
}

output "user_ids" {
  value = aws_iam_user.users.*.id
}

output "readonly_policy_arns" {
  value = { for k, v in aws_iam_policy.readonly_policy : k => v.arn }
}

output "readwrite_policy_arns" {
  value = { for k, v in aws_iam_policy.readwrite_policy : k => v.arn }
}