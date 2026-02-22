provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      project = "ct-gitops"
      env     = "dev"
      managed = "terraform"
    }
  }
}