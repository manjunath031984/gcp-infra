terraform {
  backend "gcs" {
    bucket = "terraform-state-gcp"
    prefix = "dev"
  }
}