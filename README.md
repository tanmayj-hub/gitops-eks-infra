# ct-gitops (dev) - Infrastructure (Terraform)

This repo provisions the platform layer for GitOps on AWS EKS.

- Project slug: `ct-gitops`
- Environment: `dev`
- Region: `us-east-2`
- IaC: Terraform
- Apps repo: https://github.com/tanmayj-hub/gitops-eks-apps

## Directory layout

- `envs/dev/` - Infra stack (VPC, EKS, IAM/OIDC outputs)
- `envs/dev-addons/` - Add-ons stack (Kubernetes/Helm add-ons)
- `modules/` - Reusable Terraform modules
- `docs/` - Architecture, conventions, runbooks
- `.github/workflows/` - CI checks

## Why two stacks

`envs/dev` creates EKS. `envs/dev-addons` installs cluster add-ons after EKS
exists and reads required values from infra remote state. This prevents first
apply failures caused by trying to create EKS and query it for Helm provider
configuration in the same Terraform run.

## Apply order

```powershell
# 1) Infra
cd envs/dev
terraform init
terraform apply -var="project_slug=ct-gitops" -var="environment=dev"

# 2) Add-ons
cd ../dev-addons
terraform init
terraform apply -var="project_slug=ct-gitops" -var="environment=dev"
```

## Notes

- Keep manual console changes out of band to avoid state drift.
- See `docs/conventions.md` and `docs/runbooks/01-stack-split-migration.md`.