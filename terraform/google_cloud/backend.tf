terraform {
  backend "gcs" {
    bucket = "my-terraform-state-bucket-circleci"
    prefix = "circleci/my-circleci-terraform"
  }
}