provider "google" {
  project = var.project_id
  region  = var.region
}

module "cloud-functions" {
    source            = "../modules/"
    bucket_name       = var.bucket_name
    zip_name          = "functions.zip"
    gcf_name          = "Get-github-traffic"
    project_id        = var.project_id
    dataset_id        = var.dataset_id
    authorization_key = var.authorization_key
}
