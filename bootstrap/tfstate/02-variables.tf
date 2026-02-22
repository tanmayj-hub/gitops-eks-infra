variable "region" {
  description = "AWS region for the tfstate bucket + lock table."
  type        = string
  default     = "us-east-2"
}

variable "tfstate_bucket_name" {
  description = "Globally-unique S3 bucket name for Terraform state."
  type        = string
  default     = "ct-gitops-tfstate-us-east-2"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
  default     = "ct-gitops-tfstate-lock"
}

variable "require_tls" {
  description = "If true, deny any S3 requests that are not using TLS (https)."
  type        = bool
  default     = true
}
