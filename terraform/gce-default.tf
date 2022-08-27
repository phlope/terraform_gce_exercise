# Local variables set for reuse
locals {
  windows_image = "windows-cloud/window-server-2022"
}


# --------------------
# VM Instance Template
# --------------------
# Set initial compute instance template via custom module
# This supports reusable configuration for grouping homogenous VM instances
# Supports multiple disk declaration
module "gce_instance_template" {
  source               = "./modules/compute_instance_template"
  project              = var.project
  template_name        = "gce-vm-template"
  template_description = "VM windows group template - ${var.region}"
  instance_description = "Windows VM - ${var.region}"
  machine_type         = "e2-medium"
  template_region      = var.region
  image_type           = local.windows_image
  label_env            = "gce"
  network              = google_compute_network.internal_lb_net_gce.id
  subnetwork           = google_compute_subnetwork.internal-lb-subnet.id
  additional_disks = [{
    source      = google_compute_disk.vm-datadisk.name
    auto_delete = false
    boot        = false
    },
    # Example left in as guide for attaching multiple disks per instance
    #   {
    #     source      = google_compute_disk.vm-log-disk.name
    #     auto_delete = false
    #     boot        = false
    # }
  ]
}

# -------------
# Compute Disks
# -------------
# Persistent disk declaration, can be passed to VM template per instance as shown above
resource "google_compute_disk" "vm-datadisk" {
  name    = "pd-vm"
  type    = "pd-ssd"
  project = var.project
  zone    = "europe-west2-a"
  image   = local.windows_image
  size    = 5 #GB
}

# Example additional data disk
# resource "google_compute_disk" "vm-log-disk" {
#   name                      = "log-disk"
#   type                      = "pd-ssd"
#   project                   = var.project
#   zone                      = "europe-west2-a"
#   image                     = local.windows_image
#   size                      = 10 #GB
# }

# ----------------------
# Instance Group Manager
# ----------------------
# Deploys instance group template
resource "google_compute_region_instance_group_manager" "gce-instance-manager" {
  name                      = "gce-managed-instance-group"
  provider                  = google-beta
  region                    = var.region
  distribution_policy_zones = ["${var.region}-a", "${var.region}-b"]
  version {
    instance_template = module.gce_instance_template.vm_template_id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}


# ----------------------------------------
# Network setup for TCP load balancing
# ----------------------------------------
# Also looked into HTTP proxy lb:
# - In a production setting I would consider implementing this for the benefits of logging, tracing in headers in L7 and action on SSL certs
# - For this example my aim to improve the availability of our instances, TCP lb gives us the ability to split traffic across zones and add health checks 


# VPC Network
resource "google_compute_network" "internal_lb_net_gce" {
  name                    = "gce-network"
  provider                = google-beta
  auto_create_subnetworks = false
}

# Subnet for backend
resource "google_compute_subnetwork" "internal-lb-subnet" {
  name          = "gce-ilb-subnet"
  provider      = google-beta
  ip_cidr_range = "10.0.1.0/24" #Arbitrary CIDR range
  region        = var.region
  network       = google_compute_network.internal_lb_net_gce.id
}

# Forwarding rule
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "gce-ilb-forwarding-rule"
  backend_service       = google_compute_region_backend_service.default.id
  provider              = google-beta
  region                = var.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  allow_global_access   = true
  network               = google_compute_network.internal_lb_net_gce.id
  subnetwork            = google_compute_subnetwork.internal-lb-subnet.id
}

# backend service
resource "google_compute_region_backend_service" "default" {
  name                  = "gce-l4-ilb-backend-subnet"
  provider              = google-beta
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_region_health_check.default.id]
  backend {
    group          = google_compute_region_instance_group_manager.gce-instance-manager.instance_group
    balancing_mode = "CONNECTION"
  }
}

# Health check for backend service
resource "google_compute_region_health_check" "default" {
  name     = "l4-ilb-hc"
  provider = google-beta
  region   = var.region
  http_health_check {
    port = "80"
  }
}


# --------------
# Firewall rules 
# --------------
# Grant RDP access from IP 80.193.23.74/32
resource "google_compute_firewall" "gce-rdp" {
  name          = "fw-allow-rdp"
  project       = var.project
  network       = google_compute_network.internal_lb_net_gce.id
  source_ranges = ["80.193.23.74/32"]

  allow {
    protocol = "tcp"
  }
}

# Port 443 must be open to the internet.
resource "google_compute_firewall" "gce-open-port" {
  name          = "fw-allow-rdp"
  project       = var.project
  network       = google_compute_network.internal_lb_net_gce.id
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

# Grant subnet communication
resource "google_compute_firewall" "fw_ilb_to_backends" {
  name          = "fw-l4-ilb-fw-allow-ilb-to-backends"
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.internal_lb_net_gce.id
  source_ranges = ["10.0.1.0/24"]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
}

# Allowing health check probes access: https://cloud.google.com/load-balancing/docs/health-checks#fw-netlb
resource "google_compute_firewall" "fw_hc" {
  name          = "l4-ilb-fw-allow-hc"
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.internal_lb_net_gce.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
  }
}
