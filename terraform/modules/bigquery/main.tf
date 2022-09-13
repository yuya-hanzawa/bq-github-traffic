resource "google_bigquery_dataset" "dataset" {
  dataset_id  = var.dataset_id
  description = "github traffic dataset"
  location    = "US"
}
