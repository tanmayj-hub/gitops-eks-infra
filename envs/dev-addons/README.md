# dev-addons stack

This Terraform root manages Kubernetes add-ons for `dev` after the EKS cluster
already exists.

## Scope

- AWS Load Balancer Controller (IAM policy, IRSA role, Helm release)
- Kubernetes + Helm providers configured from infra remote state

## Depends on

- `envs/dev` state (cluster name, OIDC issuer, OIDC provider ARN, VPC ID)

## Typical workflow

```powershell
cd envs/dev-addons
terraform init
terraform plan -var="project_slug=ct-gitops" -var="environment=dev"
terraform apply -var="project_slug=ct-gitops" -var="environment=dev"
```
