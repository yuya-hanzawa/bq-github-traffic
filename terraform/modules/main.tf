resource "google_storage_bucket" "create_gcf_bucket" {
  name     = var.bucket_name
  location = "US"
}

data "archive_file" "zip_source_files" {
  type        = "zip"
  source_dir  = "../../functions"
  output_path = "./src/functions.zip"
}

resource "google_storage_bucket_object" "transfer_files_bucket" {
  name   = var.zip_name
  bucket = google_storage_bucket.GCF_bucket.name
  source = "${data.archive_file.zip_source_files.output_path}"
}

resource "google_cloudfunctions_function" "create_gcf" {
  name        = var.gcf_name
  runtime     = "python39"

  available_memory_mb          = 256
  source_archive_bucket        = google_storage_bucket.create_GCF_bucket.name
  source_archive_object        = google_storage_bucket_object.transfer_files_bucket.source
  trigger_http                 = true
  https_trigger_security_level = "SECURE_ALWAYS"
  timeout                      = 60
  entry_point                  = "main"
  max_instances                = 1

  environment_variables = {
    PROJECT_ID        = var.project_id
    DATASET_ID        = var.dataset_id
    AUTHORIZATION_KEY = var.authorization_key
  }
}
