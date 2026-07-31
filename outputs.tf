output "vmss_id" {
  description = "The resource ID of the Linux Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.vmss_linux.id
}

output "vmss_name" {
  description = "The name of the Linux Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.vmss_linux.name
}

output "lb_id" {
  description = "The resource ID of the Load Balancer (null when no LB is configured)"
  value       = try(azurerm_lb.loadbalancer[0].id, null)
}

output "lb_frontend_ip_address" {
  description = "The private frontend IP address of the Load Balancer (null when no LB is configured)"
  value       = try(azurerm_lb.loadbalancer[0].frontend_ip_configuration[0].private_ip_address, null)
}
