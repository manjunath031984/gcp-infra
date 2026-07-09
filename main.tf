module "compute_instance" {

  source = "./modules/compute-instance"

  vm_name      = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
}
module "workload_identity_pool" {
  source = "./modules/workload_identity_pool"

  project_id = var.project_id

  environment = var.environment

  pool_id = "jenkins-pool"

  display_name = "Jenkins Pool"

  description = "Jenkins OIDC Workload Identity Pool"
}
