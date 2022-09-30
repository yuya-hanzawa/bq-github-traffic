resource "google_workflows_workflow" "workflow" {
  name            = var.workflows_name
  region          = var.region
  service_account = var.service_account
  source_contents = templatefile("${path.module}/workflow.yaml", {})
}

resource "google_cloud_scheduler_job" "cloud-scheduler" {
  name      = var.schduler_name
  schedule  = "0 12 * * *"
  time_zone = "Asia/Tokyo"

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/projects/${var.project_id}/locations/${var.region}/workflows/${google_workflows_workflow.workflow.name}/executions"
    body        = base64encode("{'argument':'{\"url\":\"${var.url}\", \"dataset_id\":\"${var.dataset_id}\", \"project_id\":\"${var.project_id}\"}'}")

    oauth_token {
      service_account_email = var.service_account
    }
  }
}
