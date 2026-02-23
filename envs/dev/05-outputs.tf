output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS API server endpoint"
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "Base64-encoded CA data"
  sensitive   = true
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "IAM OIDC provider ARN (for IRSA)"
}

output "cluster_oidc_issuer_url" {
  value       = module.eks.cluster_oidc_issuer_url
  description = "OIDC issuer URL (for IRSA)"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "Private subnet IDs (nodes live here)"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "Public subnet IDs (NAT gateway lives here)"
}

output "demo_app_repository_url" {
  value       = aws_ecr_repository.demo_app.repository_url
  description = "ECR repository URL for the demo app image"
}

output "hosted_zone_id" {
  value       = aws_route53_zone.public.zone_id
  description = "Route53 hosted zone ID for p1.cloudwithtanmay.com"
}

output "name_servers" {
  value       = aws_route53_zone.public.name_servers
  description = "Route53 NS records for delegating p1.cloudwithtanmay.com"
}