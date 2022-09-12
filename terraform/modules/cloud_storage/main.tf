resource "google_storage_bucket" "create_bucket" {
  name     = var.bucket_name
  location = var.bucket_location
}
