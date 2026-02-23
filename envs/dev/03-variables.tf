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

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.34"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the EKS public endpoint. Set to your public IP /32 for best security."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  description = "Instance types for the managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "root_domain" {
  description = "Public hosted zone to manage in Route53 (use a subdomain to avoid impacting the root domain)."
  type        = string
  default     = "p1.cloudwithtanmay.com"
}