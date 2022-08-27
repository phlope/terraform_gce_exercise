terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
}

variable "template_name" {
  type        = string
  description = "Name of compute instance template"
}

variable "template_description" {
  type        = string
  description = "Description of compute instance template"
}

variable "instance_description" {
  type        = string
  description = "Description of compute instance launched using template"
}

variable "project" {
  type        = string
  description = "Target project for deployment"
}


variable "machine_type" {
  type        = string
  description = "Machine resource type to provision for VM"
}

variable "template_region" {
  type        = string
  description = "Target region for deployment"
  default     = "europe-west2"
}


variable "image_type" {
  type        = string
  description = "The image from which to initialize the disk"
}

variable "label_env" {
  type        = string
  description = "Populates value for instance label 'environment'"
}

variable "network" {
  type        = string
  description = "Target network for deployment"
}

variable "subnetwork" {
  type        = string
  description = "Target subnetwork for deployment "

}

variable "additional_disks" {
  description = "Persistent disk object"
  type = list(object({
    source      = optional(string)
    auto_delete = optional(bool)
    boot        = optional(bool)
  }))
  default = [{}]
}

variable "pd_size" {
  type        = number
  description = "Persistent disk storage size in GB"
  default     = 10
}

variable "can_ip_forward" {
  type        = bool
  description = "Whether to allow sending and receiving of packets with non-matching source or destination IPs"
  default     = false
}

