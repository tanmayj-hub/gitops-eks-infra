###############################################
# Secrets Manager (Demo App)
#
# Goal: keep secret *values* out of Git.
# - The secret lives in AWS Secrets Manager.
# - Apps pull it at runtime using External Secrets Operator (ESO).
###############################################

locals {
  # required name format: ct-gitops/dev/demo-app
  demo_app_secret_name = "${var.project_slug}/${var.environment}/demo-app"
}

variable "demo_app_secret_payload" {
  description = "Key/value payload to store in Secrets Manager for demo-app (stored as a single JSON string)."
  type        = map(string)
  sensitive   = true

  # NOTE: This value is NOT sensitive for the demo, but in real projects you should set it via
  # an ignored *.auto.tfvars file or TF_VAR_* env vars.
  default = {
    WELCOME_MESSAGE = "ct-gitops dev secret — managed in AWS Secrets Manager"
  }
}

resource "aws_secretsmanager_secret" "demo_app" {
  name        = local.demo_app_secret_name
  description = "demo-app secret payload for ${var.project_slug}/${var.environment}"

  # Demo-friendly. For prod, prefer the default 30-day recovery window.
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "demo_app" {
  secret_id     = aws_secretsmanager_secret.demo_app.id
  secret_string = jsonencode(var.demo_app_secret_payload)
}