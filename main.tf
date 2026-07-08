module "compute_instance" {

  source = "./modules/compute-instance"

  vm_name      = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
}