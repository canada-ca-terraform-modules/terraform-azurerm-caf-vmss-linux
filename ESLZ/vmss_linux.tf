# ESLZ/vmss_linux.tf
# Declares the variables consumed by the module block so callers can wire their
# own var.* values in, and the module block itself. Copy this file into an L2
# blueprint to consume terraform-azurerm-caf-vmss-linux.

terraform {
  required_version = ">= 1.9"
}

variable "vmss_linux" {
  description = "Map of Linux VMSS configuration objects (key = logical name, value = vmss config object)"
  type        = any
  default     = {}
}

variable "admin_password" {
  description = "The password for the local administrator account on the virtual machines"
  type        = string
  default     = null
  sensitive   = true
}

variable "custom_data" {
  description = "Custom data (cloud-init/bash script) for VM instances, Base64-encoded"
  type        = string
  default     = null
}

module "vmss_linux" {
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-vmss-linux?ref=v1.3.0"
  for_each = var.vmss_linux

  tags            = try(each.value.tags, var.tags)
  env             = var.env
  location        = try(each.value.location, var.location)
  resource_groups = var.resource_groups
  subnets         = var.subnets
  admin_password  = try(each.value.admin_password, var.admin_password)
  custom_data     = try(each.value.custom_data, var.custom_data)
  vmss            = each.value
}
