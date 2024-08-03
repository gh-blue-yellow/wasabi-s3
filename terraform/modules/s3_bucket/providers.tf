provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
  endpoints {
    s3 = "https://s3.wasabisys.com"
  }
}