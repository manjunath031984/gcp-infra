resource "google_iam_workload_identity_pool" "this" {

  project = var.project_id

  workload_identity_pool_id = "${var.pool_id}-${var.environment}"

  display_name = var.display_name

  description = var.description

  disabled = false
}