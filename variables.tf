# General configuration variables
variable "tags" {
  type        = map(string)
  description = "Tags to be applied to all resources"
}

variable "env" {
  type        = string
  description = "Deployment environment (e.g., prod, dev, staging)"
}

variable "group" {
  type        = string
  description = "Group identifier for resource grouping"
}

variable "project" {
  type        = string
  description = "Project name identifier"
}

variable "location" {
  type        = string
  description = "Geographical location for the resources"
}

# Virtual machine scale set (VMSS) configuration
variable "vmss" {
  type        = map(any)
  default     = {}
  description = "Details about the VMSS configuration"
}

# Resource groups configuration
variable "resource_groups" {
  type        = list(map(any))
  description = "List of resource group objects"
}

# Network subnets configuration
variable "subnets" {
  type        = list(map(any))
  description = "List of subnet objects"
}

# Administrative configurations
variable "admin_password" {
  type        = string
  description = "Administrator password for virtual machines"
}
