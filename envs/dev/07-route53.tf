resource "aws_route53_zone" "public" {
  name          = var.root_domain
  comment       = "GitOps v2 public hosted zone for ${var.project_slug}-${var.environment}"
  force_destroy = false
}