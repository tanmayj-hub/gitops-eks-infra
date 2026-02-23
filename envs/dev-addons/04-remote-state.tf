data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = var.infra_state_bucket
    key    = var.infra_state_key
    region = var.infra_state_region
  }
}

locals {
  infra_cluster_name            = lookup(data.terraform_remote_state.infra.outputs, "cluster_name", "")
  infra_cluster_oidc_issuer_url = lookup(data.terraform_remote_state.infra.outputs, "cluster_oidc_issuer_url", "")
  infra_oidc_provider_arn       = lookup(data.terraform_remote_state.infra.outputs, "oidc_provider_arn", "")
  infra_vpc_id                  = lookup(data.terraform_remote_state.infra.outputs, "vpc_id", "")

  infra_hosted_zone_id = lookup(data.terraform_remote_state.infra.outputs, "hosted_zone_id", "")

  # Stage 10 (Secrets): used to scope ESO IAM to a single secret
  infra_demo_app_secret_arn  = lookup(data.terraform_remote_state.infra.outputs, "demo_app_secret_arn", "")
  infra_demo_app_secret_name = lookup(data.terraform_remote_state.infra.outputs, "demo_app_secret_name", "")

  infra_ready = alltrue([
    local.infra_cluster_name != "",
    local.infra_cluster_oidc_issuer_url != "",
    local.infra_oidc_provider_arn != "",
    local.infra_vpc_id != ""
  ])

  external_dns_ready = alltrue([
    local.infra_ready,
    local.infra_hosted_zone_id != ""
  ])
}