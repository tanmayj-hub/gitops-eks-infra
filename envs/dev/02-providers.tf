provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project = var.project_slug
      env     = var.environment
      managed = "terraform"
    }
  }
}