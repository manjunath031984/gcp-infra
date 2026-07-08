variable "project_id" {
  type = string
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "vm_name" {
  default = "terraform-vm"
}

variable "machine_type" {
  default = "e2-micro"
}