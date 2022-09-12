data "archive_file" "zip_file" {
  type        = "zip"
  source_dir  = var.script_dir
  output_path = "./src/functions.zip"
  excludes    = ["env.yaml"]
}

resource "google_storage_bucket_object" "upload_file" {
  name   = var.zip_name
  bucket = var.bucket_name
  source = data.archive_file.zip_file.output_path
}

resource "google_cloudfunctions_function" "function" {
  name    = var.gcf_name
  runtime = "python39"

  available_memory_mb          = var.memory
  source_archive_bucket        = google_storage_bucket_object.upload_file.bucket
  source_archive_object        = google_storage_bucket_object.upload_file.name
  trigger_http                 = true
  https_trigger_security_level = "SECURE_ALWAYS"
  timeout                      = var.timeout
  entry_point                  = "main"

  environment_variables = yamldecode(file("../../functions/env.yaml"))
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
