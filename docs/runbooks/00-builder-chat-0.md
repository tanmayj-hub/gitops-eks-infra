# Runbook: Builder Chat 0 — Infra Repo Bootstrap

## Goal
Create an industry-aligned repo structure and conventions for Terraform infra, without creating AWS resources.

## Done
- Repo exists: `tanmayj-hub/gitops-eks-infra`
- Folder structure present (`envs/dev`, `modules`, `docs`, `.github`)
- Added conventions + architecture docs
- Normalized formatting + LF endings

## Validation
- `README.md` has scope, layout, workflow
- CI workflow exists and parses
- `docs/conventions.md` and `docs/architecture.md` are non-empty

## Next
Proceed to Builder Chat 1: remote Terraform state bootstrap (S3 + DynamoDB) and AWS provider authentication.
