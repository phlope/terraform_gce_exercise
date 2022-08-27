provider "google" {
  region  = var.region
  project = var.project
}

provider "google-beta" {
  region  = var.region
  project = var.project
}

# In a multi-tenant working environment I would store state remotely in GCS
# terraform {
#   backend "gcs" {
#     bucket  = "tf-state"
#     prefix  = "terraform/state"
#   }
# }
