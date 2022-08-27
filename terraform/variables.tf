variable "environment" {
  type        = string
  description = "Target environment for resource provisioning"
  default     = "test"
}

variable "project" {
  type        = string
  description = "Target project for deployment"
  default     = "gce-test"
}

variable "region" {
  type        = string
  description = "Target region for deployment"
}
