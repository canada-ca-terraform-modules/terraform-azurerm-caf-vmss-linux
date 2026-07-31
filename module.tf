resource "azurerm_linux_virtual_machine_scale_set" "vmss_linux" {
  name                            = local.vmss_resource_name
  location                        = var.location
  resource_group_name             = var.resource_groups[var.vmss.resource_group_name].name
  sku                             = var.vmss.sku
  instances                       = var.vmss.instances
  admin_username                  = try(var.vmss.admin_username, "azureadmin")
  admin_password                  = var.admin_password
  computer_name_prefix            = try(var.vmss.computer_name_prefix, "vmsslin-") # Optional. eg: "devopsw-"
  disable_password_authentication = false
  custom_data                     = var.custom_data
  tags                            = var.tags

  overprovision          = var.vmss.overprovision
  single_placement_group = var.vmss.single_placement_group

  source_image_reference {
    publisher = var.vmss.source_image_reference.publisher
    offer     = var.vmss.source_image_reference.offer
    sku       = var.vmss.source_image_reference.sku
    version   = var.vmss.source_image_reference.version
  }

  os_disk {
    storage_account_type = var.vmss.os_disk.storage_account_type
    caching              = var.vmss.os_disk.caching
  }

  dynamic "scale_in" {
    for_each = try(var.vmss.scale_in, false) != false ? [1] : []
    content {
      rule                   = try(scale_in.value.rule, null)
      force_deletion_enabled = try(scale_in.value.force_deletion_enabled, null)
    }
  }

  network_interface {
    name    = local.nic_name
    primary = true

    ip_configuration {
      name                                   = "ipconfig1"
      primary                                = true
      subnet_id                              = var.subnets[var.vmss.subnet_name].id
      load_balancer_backend_address_pool_ids = try(var.vmss.lb, null) != null ? [azurerm_lb_backend_address_pool.loadbalancer-lbbp[0].id] : null
    }
  }

  lifecycle {
    precondition {
      condition     = length(local.vmss_resource_name) <= 64
      error_message = "The generated VMSS name '${local.vmss_resource_name}' is ${length(local.vmss_resource_name)} characters, which exceeds the Azure 64-character limit. Shorten vmss.userDefinedString or vmss.postfix, or set vmss.vmss_name to an explicit name."
    }
    ignore_changes = [tags, instances, identity] # ignore changes made outside of Terraform (e.g. tags by App Services, identity by external tooling)
  }
}
