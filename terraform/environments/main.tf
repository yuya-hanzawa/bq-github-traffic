variable project_id {}
variable region {}
variable dataset_id {}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "gcf_bucket" {
  source      = "../modules/cloud_storage/"
  bucket_name = "github-traffic-bucket"
}

module "bq-dataset" {
  source     = "../modules/bigquery/"
  dataset_id = var.dataset_id
}

module "cloud_functions" {
  source      = "../modules/cloud_functions/"
  script_dir  = "../../functions/"
  zip_name    = "functions.zip"
  bucket_name = module.gcf_bucket.gcs_name
  gcf_name    = "Get-github-traffic"
}
