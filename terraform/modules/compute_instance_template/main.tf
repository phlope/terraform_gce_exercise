# Creates VM template per module call with user-defined values
resource "google_compute_instance_template" "vm-template" {
  name                 = var.template_name
  description          = var.template_description
  instance_description = var.instance_description
  machine_type         = var.machine_type
  project              = var.project
  region               = var.template_region
  can_ip_forward       = var.can_ip_forward
  labels = {
    environment = var.label_env
  }

  # Default scheduling rules
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  # Boot disk using user chosen image
  disk {
    source_image = var.image_type
    auto_delete  = true
    boot         = true
  }

  # Dynamically attaches list of disk objects, defaulting to null
  dynamic "disk" {
    for_each = var.additional_disks
    content {
      source      = lookup(disk, "source", null)
      auto_delete = lookup(disk, "auto_delete", false)
      boot        = lookup(disk, "boot", false)
    }
  }

  # Project default network
  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  lifecycle {
    create_before_destroy = true
  }
}


