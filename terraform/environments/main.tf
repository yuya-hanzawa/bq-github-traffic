variable project_id {}
variable dataset_id {}
variable service_account_id {}

provider "google" {
  project = var.project_id
  region  = "us-central1"
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

module "workflows" {
  source                = "../modules/workflows/"
  workflows_name        = "github-traffic-workflow"
  service_account       = var.service_account_id
  schduler_name         = "workflow-schduler"
  project_id            = var.project_id
}
