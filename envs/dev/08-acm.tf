# envs/dev/08-acm.tf

resource "aws_acm_certificate" "p1_wildcard" {
  domain_name               = "*.${var.root_domain}" # *.p1.cloudwithtanmay.com
  subject_alternative_names = [var.root_domain]      # optional but useful (covers p1.cloudwithtanmay.com)
  validation_method         = "DNS"

  tags = {
    Name        = "${var.project_slug}-${var.environment}-p1-wildcard"
    Environment = var.environment
    Project     = var.project_slug
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "p1_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.p1_wildcard.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.public.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "p1_wildcard" {
  certificate_arn         = aws_acm_certificate.p1_wildcard.arn
  validation_record_fqdns = [for r in aws_route53_record.p1_acm_validation : r.fqdn]
}