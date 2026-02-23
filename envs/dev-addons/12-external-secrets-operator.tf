# --- External Secrets Operator (ESO) ---
# Syncs secrets from AWS Secrets Manager into Kubernetes Secrets.
# Installed via Helm (Terraform-managed) and uses IRSA (least-privilege to ONE secret).

locals {
  eso_namespace = "external-secrets"
  eso_sa_name   = "external-secrets"

  eso_ready = alltrue([
    local.infra_ready,
    local.infra_demo_app_secret_arn != "",
    local.infra_demo_app_secret_name != ""
  ])
}

# IAM policy: read ONLY our demo secret
data "aws_iam_policy_document" "external_secrets" {
  count = local.eso_ready ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = [local.infra_demo_app_secret_arn]
  }
}

resource "aws_iam_policy" "external_secrets" {
  count = local.eso_ready ? 1 : 0

  name        = "${var.project_slug}-${var.environment}-external-secrets-policy"
  description = "ESO read-only access to ${local.infra_demo_app_secret_name}"
  policy      = data.aws_iam_policy_document.external_secrets[0].json
}

# IRSA assume role policy
data "aws_iam_policy_document" "external_secrets_assume" {
  count = local.eso_ready ? 1 : 0

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
      values   = ["system:serviceaccount:${local.eso_namespace}:${local.eso_sa_name}"]
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  count = local.eso_ready ? 1 : 0

  name               = "${var.project_slug}-${var.environment}-external-secrets-irsa"
  description        = "IRSA role for External Secrets Operator (${local.eso_namespace}/${local.eso_sa_name})"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume[0].json
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  count = local.eso_ready ? 1 : 0

  role       = aws_iam_role.external_secrets[0].name
  policy_arn = aws_iam_policy.external_secrets[0].arn
}

resource "helm_release" "external_secrets" {
  count = local.eso_ready ? 1 : 0

  name      = "external-secrets"
  namespace = local.eso_namespace

  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"

  # Pin chart version (prefer latest 2.x).
  # Confirm available versions: helm search repo external-secrets/external-secrets --versions | head
  version = "2.0.1"

  create_namespace = true

  # Make Helm/Terraform resilient
  timeout         = 900
  atomic          = true
  cleanup_on_fail = true
  wait            = true

  values = [
    yamlencode({
      installCRDs  = true
      replicaCount = 1

      serviceAccount = {
        create = true
        name   = local.eso_sa_name
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets[0].arn
        }
      }
    })
  ]

  depends_on = [aws_iam_role_policy_attachment.external_secrets]
}