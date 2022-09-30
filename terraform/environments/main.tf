variable project_id {}
variable dataset_id {}
variable service_account_id {}
variable url {}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

module "bq-dataset" {
  source     = "../modules/bigquery/"
  dataset_id = var.dataset_id
}

module "workflows" {
  source          = "../modules/workflows/"
  workflows_name  = "github-traffic-workflow"
  service_account = var.service_account_id
  schduler_name   = "workflow-schduler"
  project_id      = var.project_id
  dataset_id      = var.dataset_id
  url             = var.url
}
