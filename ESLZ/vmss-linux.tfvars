vmss_linux = [
  {
      # custom_name = "some-custom-name" # Optional. ONLY use if you really really really don't want to use the auto generated name
      userDefinedString = "test" # Max 55 chars
      postfix           = "01"
      # computer_name_prefix = "vmsslin-"         # Optional. eg: "test-"
      resource_group_name = "Project"
      subnet_name         = "OZ"
      sku                 = "Standard_D2s_v3"
      admin_password      = "Canada123!"
      # upgrade_mode        = "Automatic"
      source_image_reference = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-LTS"
        version   = "latest"
      }
      instances              = 2
      single_placement_group = false
      overprovision          = false
      os_disk = {
        storage_account_type = "StandardSSD_LRS"
        caching              = "ReadWrite"
      }
  #   # custom_data = "post_install_scripts/vmss-script.sh"
  #   # The next block is optional. Uncomment and configure to use it to configure a LB in front of the VMSS
  #   lb = {
  #     # custom_name = "some-custom-name" # Optional. ONLY use if you really really really don't want to use the auto generated name
  #     private_ip_address_allocation = "Dynamic" # Optional: Dynamic or Static. Default to Static
  #     # private_ip_address            = "10.10.10.10"
  #     # subnet_name                   = "MAZ"      # Optional. Use only if you want the subnet for the LB NIC to be different than the VMSS
  #     sku                           = "Standard" # Optional. Default to Standard
  #     probes = {
  #       tcp443 = {
  #         port                = 443 # Port to probe to detect health of vm
  #         interval_in_seconds = 5   # Optional. Default to 5
  #       }
  #     }
  #     rules = {
  #       tcp443 = {
  #         protocol           = "Tcp"
  #         frontend_port      = 443
  #         backend_port       = 443
  #         probe_name         = "tcp443"
  #         load_distribution  = "SourceIPProtocol"
  #         enable_floating_ip = true
  #       },
  #       tcp80 = {
  #         protocol           = "Tcp"
  #         frontend_port      = 80
  #         backend_port       = 80
  #         probe_name         = "tcp443"
  #         load_distribution  = "SourceIPProtocol"
  #         enable_floating_ip = true
  #       }
  #     }
  #   }
  }
]
