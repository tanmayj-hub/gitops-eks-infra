# --- AWS Load Balancer Controller (LBC) v3.0.0 ---
# Installs via Helm (Terraform-managed) and uses IRSA (IAM role for ServiceAccount).

locals {
  cluster_name             = local.infra_cluster_name
  cluster_oidc_issuer_url  = local.infra_cluster_oidc_issuer_url
  oidc_provider_arn        = local.infra_oidc_provider_arn
  vpc_id                   = local.infra_vpc_id
  eks_oidc_issuer_hostpath = replace(local.cluster_oidc_issuer_url, "https://", "")
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  count = local.infra_ready ? 1 : 0

  name        = "${var.project_slug}-${var.environment}-aws-lbc-policy"
  description = "IAM policy for AWS Load Balancer Controller (v3.0.0)"

  # Official policy (vendored in repo):
  # https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v3.0.0/docs/install/iam_policy.json
  policy = file("${path.module}/iam/aws-load-balancer-controller/iam_policy.json")
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume" {
  count = local.infra_ready ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_hostpath}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  count = local.infra_ready ? 1 : 0

  name               = "${var.project_slug}-${var.environment}-aws-lbc-irsa"
  description        = "IRSA role for AWS Load Balancer Controller (kube-system/aws-load-balancer-controller)"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume[0].json
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  count = local.infra_ready ? 1 : 0

  role       = aws_iam_role.aws_load_balancer_controller[0].name
  policy_arn = aws_iam_policy.aws_load_balancer_controller[0].arn
}

resource "helm_release" "aws_load_balancer_controller" {
  count = local.infra_ready ? 1 : 0

  name      = "aws-load-balancer-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.0.0"

  create_namespace = false

  # Chart v3.0.0 values reference (shows clusterName/region/vpcId/serviceAccount/replicaCount):
  # https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v3.0.0/helm/aws-load-balancer-controller/values.yaml
  values = [
    yamlencode({
      clusterName  = local.cluster_name
      region       = var.aws_region
      vpcId        = local.vpc_id
      replicaCount = 2

      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller[0].arn
        }
      }
    })
  ]

  depends_on = [aws_iam_role_policy_attachment.aws_load_balancer_controller]
}
