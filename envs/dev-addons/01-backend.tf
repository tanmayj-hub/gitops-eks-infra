terraform {
  backend "s3" {
    bucket         = "ct-gitops-tfstate-us-east-2"
    key            = "ct-gitops/dev/addons/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "ct-gitops-tfstate-lock"
    encrypt        = true
  }
}
