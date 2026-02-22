# --- Kubernetes + Helm providers (wired to existing EKS) ---
# Reads cluster details from infra remote state.

data "aws_eks_cluster" "this" {
  count = local.infra_ready ? 1 : 0
  name  = local.infra_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  count = local.infra_ready ? 1 : 0
  name  = local.infra_cluster_name
}

provider "kubernetes" {
  host                   = try(data.aws_eks_cluster.this[0].endpoint, "https://127.0.0.1")
  cluster_ca_certificate = try(base64decode(data.aws_eks_cluster.this[0].certificate_authority[0].data), "")
  token                  = try(data.aws_eks_cluster_auth.this[0].token, "")
}

provider "helm" {
  kubernetes = {
    host                   = try(data.aws_eks_cluster.this[0].endpoint, "https://127.0.0.1")
    cluster_ca_certificate = try(base64decode(data.aws_eks_cluster.this[0].certificate_authority[0].data), "")
    token                  = try(data.aws_eks_cluster_auth.this[0].token, "")
  }
}
