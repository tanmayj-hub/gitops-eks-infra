# --- Argo CD (private, ClusterIP only) ---
# Helm chart: argo/argo-cd (argoproj repo)
# Chart version pinned: 9.4.3 (Argo CD appVersion v3.3.1)

resource "helm_release" "argocd" {
  count = local.infra_ready ? 1 : 0

  name      = "argocd"
  namespace = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.4.3"

  # Create argocd namespace automatically
  create_namespace = true

  # Keep it private: no Ingress, no LB. Access via port-forward.
  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP"
        }
      }

      # Reduce footprint for 1-node demo
      dex = {
        enabled = false
      }

      notifications = {
        enabled = false
      }
    })
  ]

  depends_on = [
    terraform_data.infra_ready_guard
  ]
}