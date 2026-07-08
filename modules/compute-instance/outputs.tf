output "instance_name" {
  value = google_compute_instance.vm.name
}

output "instance_id" {
  value = google_compute_instance.vm.id
}

output "internal_ip" {
  value = google_compute_instance.vm.network_interface[0].network_ip
}

output "external_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}