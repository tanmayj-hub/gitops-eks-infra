# --- ExternalDNS (Route53) ---
# Watches Ingress resources and creates/updates Route53 records.
# Installed via Helm (Terraform-managed) and uses IRSA (least-privilege to hosted zone).

locals {
  external_dns_namespace = "kube-system"
  external_dns_sa_name   = "external-dns"

  hosted_zone_id  = local.infra_hosted_zone_id
  hosted_zone_arn = "arn:aws:route53:::hostedzone/${local.hosted_zone_id}"
}

# IAM policy (least privilege to ONLY this hosted zone)
data "aws_iam_policy_document" "external_dns" {
  count = local.external_dns_ready ? 1 : 0

  # Write: only this hosted zone
  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = [local.hosted_zone_arn]
  }

  # Read: only this hosted zone
  statement {
    effect = "Allow"
    actions = [
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
    ]
    resources = [local.hosted_zone_arn]
  }

  # Read-only global list/lookup APIs Route53 needs
  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:GetChange",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  count = local.external_dns_ready ? 1 : 0

  name        = "${var.project_slug}-${var.environment}-external-dns-policy"
  description = "ExternalDNS Route53 access scoped to hosted zone ${var.root_domain}"
  policy      = data.aws_iam_policy_document.external_dns[0].json
}

# IRSA assume role policy
data "aws_iam_policy_document" "external_dns_assume" {
  count = local.external_dns_ready ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.infra_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_hostpath}:sub"
      values   = ["system:serviceaccount:${local.external_dns_namespace}:${local.external_dns_sa_name}"]
    }
  }
}

resource "aws_iam_role" "external_dns" {
  count = local.external_dns_ready ? 1 : 0

  name               = "${var.project_slug}-${var.environment}-external-dns-irsa"
  description        = "IRSA role for ExternalDNS (${local.external_dns_namespace}/${local.external_dns_sa_name})"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume[0].json
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  count = local.external_dns_ready ? 1 : 0

  role       = aws_iam_role.external_dns[0].name
  policy_arn = aws_iam_policy.external_dns[0].arn
}

resource "helm_release" "external_dns" {
  count = local.external_dns_ready ? 1 : 0

  name      = "external-dns"
  namespace = local.external_dns_namespace

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "9.0.3"

  create_namespace = false

  # Make Helm/Terraform resilient
  timeout         = 900
  atomic          = true
  cleanup_on_fail = true
  wait            = true

  values = [
    yamlencode({
      provider = "aws"
      sources  = ["ingress"]

      # safest for demo: do not delete records
      policy   = "upsert-only"
      registry = "txt"

      # ensures no record conflicts across clusters
      txtOwnerId    = local.infra_cluster_name
      domainFilters = [var.root_domain]

      # IMPORTANT: use chart-native filter (avoids the '--0' crash)
      zoneIdFilters = [local.hosted_zone_id]

      aws = {
        region   = var.aws_region
        zoneType = "public"
      }

      # Bitnami public images for some versions are no longer available;
      # legacy repo works for this pinned tag.
      global = {
        security = {
          allowInsecureImages = true
        }
      }

      image = {
        registry   = "docker.io"
        repository = "bitnamilegacy/external-dns"
        tag        = "0.18.0-debian-12-r4"
      }

      serviceAccount = {
        create = true
        name   = local.external_dns_sa_name
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns[0].arn
        }
      }
    })
  ]

  depends_on = [aws_iam_role_policy_attachment.external_dns]
}