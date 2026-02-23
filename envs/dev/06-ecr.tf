resource "aws_ecr_repository" "demo_app" {
  name         = "${var.project_slug}/demo-app" # -> ct-gitops/demo-app
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_slug}/demo-app"
    Environment = var.environment
    Project     = var.project_slug
  }
}