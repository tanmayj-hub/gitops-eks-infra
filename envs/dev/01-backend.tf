terraform {
  backend "s3" {
    bucket         = "ct-gitops-tfstate-us-east-2"   # TODO (Builder Chat 1)
    key            = "ct-gitops/dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "ct-gitops-tfstate-lock"        # TODO (Builder Chat 1)
    encrypt        = true
  }
}