# Conventions — gitops-eks-infra

## Scope
This repo owns Terraform code that provisions the **platform layer** for `ct-gitops` in `dev` (us-east-2).

## Naming
- Prefix: `ct-gitops`
- Environment suffix: `dev`
- Examples (placeholders):
  - S3 state bucket: `ct-gitops-tfstate-us-east-2`
  - DynamoDB lock table: `ct-gitops-tfstate-lock`

## Terraform structure
- `envs/dev/` contains:
  - provider config, backend config, and module wiring
  - environment variables + tfvars examples
- `modules/` contains reusable modules (no hardcoded env values inside modules)

## State + locking (later)
Remote state uses **S3 + DynamoDB**.
- CI uses `terraform init -backend=false` until state is created.
- After state exists, we remove `-backend=false` locally and in automation.

## Version pinning
- Terraform pinned via `.terraform-version`
- Toolchain pinning via `.tool-versions` (optional but recommended)

## Code style
- Run `terraform fmt -recursive` before pushing
- Keep modules small and explicit (inputs/outputs)
