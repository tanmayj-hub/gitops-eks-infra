# Stack split changes (implemented)

## Summary

Implemented a long-term Terraform structure fix by splitting `dev` into two
root stacks:

- `envs/dev` for infrastructure (VPC + EKS)
- `envs/dev-addons` for cluster add-ons (Helm/Kubernetes resources)

## Files and behavior changes

- Added new add-ons stack at `envs/dev-addons`.
- Added remote-state wiring from add-ons stack to infra outputs.
- Moved AWS Load Balancer Controller resources to add-ons stack.
- Removed Kubernetes/Helm provider requirements from infra stack.
- Updated CI to validate both stacks.
- Updated root `README.md` apply order and architecture notes.

## Deploy order

1. Apply `envs/dev`.
2. Apply `envs/dev-addons`.

Detailed runbook: `docs/runbooks/01-stack-split-migration.md`.
