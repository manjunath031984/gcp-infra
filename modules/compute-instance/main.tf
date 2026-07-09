resource "google_compute_instance" "vm" {

  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {

    initialize_params {

      image = "projects/debian-cloud/global/images/family/debian-12"

      size = 20

      type = "pd-standard"
    }
  }

  network_interface {

    network = "default"

    access_config {}
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  labels = {
    environment = "dev"
    owner       = "terraform"
  }

  tags = [
    "terraform",
    "gcp"
  ]
}
