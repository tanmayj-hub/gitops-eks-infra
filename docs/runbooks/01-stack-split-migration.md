# Terraform stack split migration (dev)

## What changed

- `envs/dev/` is now infra-only (VPC + EKS + outputs).
- Kubernetes/Helm provider wiring was moved out of `envs/dev`.
- AWS Load Balancer Controller resources were moved out of `envs/dev`.
- New root stack added: `envs/dev-addons/`.
- Add-ons stack reads infra outputs using `terraform_remote_state`.
- CI now validates both `envs/dev` and `envs/dev-addons`.

## Why this change

The previous single-stack setup mixed:

- EKS creation, and
- data lookups/providers that require an existing EKS cluster.

That can fail on the first plan/apply with:

- `reading EKS Cluster (...) : couldn't find resource`

Splitting stacks removes this ordering problem.

## New execution order

```powershell
# Infra first
cd envs/dev
terraform init
terraform apply -var="project_slug=ct-gitops" -var="environment=dev"

# Add-ons second
cd ../dev-addons
terraform init
terraform apply -var="project_slug=ct-gitops" -var="environment=dev"
```

## Backend/state layout

- Infra state key: `ct-gitops/dev/terraform.tfstate`
- Add-ons state key: `ct-gitops/dev/addons/terraform.tfstate`

Both states use the same backend bucket and lock table.
