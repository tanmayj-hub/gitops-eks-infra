############################################################
# GitHub Actions OIDC -> AssumeRole -> Push to ECR
############################################################

data "aws_caller_identity" "current" {}

locals {
  # Hard-requirement values from your Stage 13 spec
  github_owner  = "tanmayj-hub"
  github_repo   = "ct-gitops-demo-app"
  github_branch = "main"

  github_sub = "repo:${local.github_owner}/${local.github_repo}:ref:refs/heads/${local.github_branch}"

  # ECR repo already exists in this stack: aws_ecr_repository.demo_app (ct-gitops/demo-app)
  ecr_repo_arn = aws_ecr_repository.demo_app.arn
}

# Fetch the current TLS thumbprint for token.actions.githubusercontent.com
data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "${var.project_slug}-${var.environment}-github-actions-oidc"
    Environment = var.environment
    Project     = var.project_slug
  }
}

data "aws_iam_policy_document" "gha_assume_role" {
  statement {
    sid     = "GitHubActionsAssumeRoleWithOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Lock to ONLY: repo tanmayj-hub/ct-gitops-demo-app, branch main
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.github_sub]
    }
  }
}

resource "aws_iam_role" "gha_ecr_push" {
  name               = "${var.project_slug}-${var.environment}-gha-ecr-push"
  assume_role_policy = data.aws_iam_policy_document.gha_assume_role.json
}

data "aws_iam_policy_document" "gha_ecr_push_policy" {
  # ECR auth token MUST be "*"
  statement {
    sid       = "ECRGetAuthorizationToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # Push rights scoped to ONLY your demo app repo ARN
  statement {
    sid    = "ECRPushToDemoRepoOnly"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:DescribeRepositories"
    ]
    resources = [local.ecr_repo_arn]
  }
}

resource "aws_iam_policy" "gha_ecr_push" {
  name   = "${var.project_slug}-${var.environment}-gha-ecr-push-policy"
  policy = data.aws_iam_policy_document.gha_ecr_push_policy.json

  tags = {
    Name        = "${var.project_slug}-${var.environment}-gha-ecr-push-policy"
    Environment = var.environment
    Project     = var.project_slug
  }
}

resource "aws_iam_role_policy_attachment" "gha_ecr_push_attach" {
  role       = aws_iam_role.gha_ecr_push.name
  policy_arn = aws_iam_policy.gha_ecr_push.arn
}