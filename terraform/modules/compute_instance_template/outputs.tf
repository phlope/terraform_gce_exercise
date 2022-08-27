# Outputting instance template id for reference in managed instance group
output "vm_template_id" {
  value = google_compute_instance_template.vm-template.id
}
