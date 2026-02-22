# --- GitOps Bootstrap (Root Application) ---
# Creates ONE Argo CD Application from Terraform.
# Argo CD then syncs the rest (AppProject + child Applications) from the apps repo.

resource "kubernetes_manifest" "argocd_root_application" {
  count = local.infra_ready ? 1 : 0

  manifest = yamldecode(<<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: ct-gitops-dev-root
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      # IMPORTANT: keep root in "default" project so it can create the ct-gitops AppProject safely.
      project: default

      source:
        repoURL: https://github.com/tanmayj-hub/gitops-eks-apps.git
        targetRevision: main
        path: clusters/ct-gitops-dev

      destination:
        server: https://kubernetes.default.svc
        namespace: argocd

      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
  YAML
  )

  # CRDs must exist before we can create Application objects
  depends_on = [
    helm_release.argocd
  ]
}