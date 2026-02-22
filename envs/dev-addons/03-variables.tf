variable "project_slug" {
  description = "Project slug/prefix used for naming (e.g., ct-gitops)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "infra_state_bucket" {
  description = "S3 bucket that stores infra Terraform state"
  type        = string
  default     = "ct-gitops-tfstate-us-east-2"
}

variable "infra_state_key" {
  description = "S3 key for infra Terraform state"
  type        = string
  default     = "ct-gitops/dev/terraform.tfstate"
}

variable "infra_state_region" {
  description = "AWS region of the infra Terraform state bucket"
  type        = string
  default     = "us-east-2"
}
