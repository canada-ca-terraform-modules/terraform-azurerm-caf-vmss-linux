# ESLZ/vmss_linux.tfvars
# Example tfvars for the terraform-azurerm-caf-vmss-linux module, consumed via
# the ESLZ/vmss_linux.tf module block. Copy and adjust for your blueprint.

vmss_linux = {
  # --- EXISTING ENTRIES (unchanged) ---
  app01 = {
    resource_group_name = "app-rg"
    subnet_name         = "app-subnet"
    sku                 = "Standard_D2s_v5"
    instances           = 2
    postfix             = "web"
    userDefinedString   = "myapp"

    overprovision          = true
    single_placement_group = true

    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts"
      version   = "latest"
    }

    os_disk = {
      storage_account_type = "Standard_LRS"
      caching              = "ReadWrite"
    }

    # Optional: name overrides for existing infra whose real names diverge from the
    # naming formula (avoids destroy/recreate). Leave commented to use generated names.
    # vmss_name = "existing-vmss-name"
    # nic_name  = "existing-vmss-nic1"

    # Optional: attach a Load Balancer
    # lb = {
    #   sku = "Standard"
    #   # name              = "existing-lb-name"          # Optional override
    #   # frontend_name     = "existing-lb-frontend-name"  # Optional override
    #   # backend_pool_name = "existing-lb-backend-name"   # Optional override
    #   probes = {
    #     tcp443 = { port = 443, interval_in_seconds = 5 }
    #   }
    #   rules = {
    #     tcp443 = {
    #       protocol            = "Tcp"
    #       frontend_port       = 443
    #       backend_port        = 443
    #       probe_name          = "tcp443"
    #       load_distribution   = "SourceIPProtocol"
    #       floating_ip_enabled = true # azurerm >= 5.0 name; enable_floating_ip still accepted
    #     }
    #   }
    # }
  }
}
