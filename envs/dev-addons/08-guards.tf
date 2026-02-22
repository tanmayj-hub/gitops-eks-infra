resource "terraform_data" "infra_ready_guard" {
  input = "infra-state-ready-check"

  lifecycle {
    precondition {
      condition     = local.infra_ready
      error_message = "Infra state is missing required outputs. Apply envs/dev first, then run envs/dev-addons."
    }
  }
}
