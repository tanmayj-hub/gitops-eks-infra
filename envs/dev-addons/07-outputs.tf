output "aws_load_balancer_controller_role_arn" {
  description = "IRSA role ARN used by AWS Load Balancer Controller"
  value       = try(aws_iam_role.aws_load_balancer_controller[0].arn, null)
}

output "external_dns_role_arn" {
  description = "IRSA role ARN used by ExternalDNS"
  value       = try(aws_iam_role.external_dns[0].arn, null)
}
