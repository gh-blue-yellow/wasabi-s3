module "s3_buckets" {
  source       = "./modules/s3_bucket"
  access_key   = var.access_key
  secret_key   = var.secret_key
  bucket_names = ["sales-data-bucket", "marketing-data-bucket", "engineering-data-bucket", "finance-data-bucket", "operations-data-bucket"]
  user_names   = ["alice", "bob", "charlie", "backup"]

  user_policy_attachments = {
    alice = [
      module.s3_buckets.readwrite_policy_arns["sales-data-bucket"],
      module.s3_buckets.readwrite_policy_arns["marketing-data-bucket"],
      module.s3_buckets.readonly_policy_arns["engineering-data-bucket"]
    ]
    bob = [
      module.s3_buckets.readwrite_policy_arns["sales-data-bucket"],
      module.s3_buckets.readwrite_policy_arns["marketing-data-bucket"],
      module.s3_buckets.readwrite_policy_arns["engineering-data-bucket"],
      module.s3_buckets.readwrite_policy_arns["finance-data-bucket"],
      module.s3_buckets.readwrite_policy_arns["operations-data-bucket"]
    ]
    charlie = [
      module.s3_buckets.readwrite_policy_arns["operations-data-bucket"],
      module.s3_buckets.readonly_policy_arns["finance-data-bucket"]
    ]
    backup = [
      module.s3_buckets.readonly_policy_arns["sales-data-bucket"],
      module.s3_buckets.readonly_policy_arns["marketing-data-bucket"],
      module.s3_buckets.readonly_policy_arns["engineering-data-bucket"],
      module.s3_buckets.readonly_policy_arns["finance-data-bucket"],
      module.s3_buckets.readonly_policy_arns["operations-data-bucket"]
    ]
  }
}