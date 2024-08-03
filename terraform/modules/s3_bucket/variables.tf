variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "bucket_names" {
  type = list(string)
}

variable "user_names" {
  type = list(string)
}

variable "user_policy_attachments" {
  type = map(list(string))
}
