# Architecture (high level) — ct-gitops v2

Two-repo model:

1) **gitops-eks-infra**
- Terraform provisions: VPC → EKS → ECR → Argo CD (Helm)
- Bootstraps Argo CD to point at the apps repo

2) **gitops-eks-apps**
- GitOps desired state: namespaces, Argo Applications, Kustomize overlays, app manifests

Flow (later):
Dev pushes → PR merge → Terraform provisions infra → Argo CD syncs desired state from apps repo → workloads run on EKS.
