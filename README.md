# ct-gitops (dev) — Infrastructure (Terraform)

This repo provisions the **platform layer** for an industry-aligned GitOps v2 project on **AWS EKS**.

- **Project slug:** `ct-gitops`
- **Environment:** `dev`
- **Region:** `us-east-2`
- **IaC:** Terraform
- **GitOps engine:** Argo CD (installed via Helm from Terraform later)
- **Apps repo:** https://github.com/tanmayj-hub/gitops-eks-apps

> Builder Chat 0 scope: repo structure + conventions only. No AWS resources are created yet.

## What will live here (later)
- VPC + networking (cost-aware defaults)
- EKS cluster + managed node groups
- ECR repos for images
- Argo CD install (Helm) + bootstrap to the apps repo

## Directory layout
- `envs/dev/` — environment entrypoint (providers, backend, module wiring)
- `modules/` — reusable Terraform modules (eks, argocd, ecr, etc.)
- `docs/` — architecture + conventions + runbooks
- `.github/workflows/` — CI checks (fmt/validate)

## Conventions (short)
- Naming: prefix with `ct-gitops`, include env (`dev`) where needed
- Tagging: every AWS resource gets default tags via provider `default_tags`
- No manual changes in AWS console once provisioning starts (avoid drift)

See: `docs/conventions.md`

## How we work (PR workflow)
- Branch from `main` → open PR → CI runs → 1 approval → squash merge.
- `main` is the source of truth for infra.

## Builder Chat checkpoints
- Builder Chat 0: Repos + folders + conventions ✅
- Builder Chat 1: Remote state (S3 + DynamoDB) + provider bootstrap
- Builder Chat 2: VPC + EKS
- Builder Chat 3: ECR + Argo CD install + GitOps bootstrap
