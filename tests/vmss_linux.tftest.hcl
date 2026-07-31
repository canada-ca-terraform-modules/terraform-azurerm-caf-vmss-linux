# tests/vmss_linux.tftest.hcl
# Functional tests for the terraform-azurerm-caf-vmss-linux module.
# mock_provider intercepts all API calls — no Azure credentials needed.

mock_provider "azurerm" {}

variables {
  tags            = { environment = "test" }
  env             = "Dev"
  location        = "canadacentral"
  resource_groups = { rg-test = { name = "rg-test", location = "canadacentral" } }
  subnets         = { subnet-test = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test" } }
  admin_password  = "P@ssw0rd-Test-1234!"
}

run "naming_convention" {
  command = plan

  variables {
    vmss = {
      resource_group_name = "rg-test"
      subnet_name         = "subnet-test"
      sku                 = "Standard_D2s_v5"
      instances           = 1
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
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.vmss_linux.name == "DevSLG-myappweb-vmss"
    error_message = "VMSS name must follow {env4}{serverType3}-{userDefinedString}{postfix3}-vmss convention"
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.vmss_linux.network_interface[0].name == "DevSLG-myappweb-nic1"
    error_message = "NIC name must follow {vmss_name}-nic1 convention"
  }
}

run "default_values" {
  command = plan

  variables {
    vmss = {
      resource_group_name = "rg-test"
      subnet_name         = "subnet-test"
      sku                 = "Standard_D2s_v5"
      instances           = 1
      postfix             = "app"
      userDefinedString   = "minimal"

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
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.vmss_linux.admin_username == "azureadmin"
    error_message = "admin_username must default to azureadmin when not supplied"
  }

  assert {
    condition     = length(azurerm_lb.loadbalancer) == 0
    error_message = "No load balancer should be created when vmss.lb is not supplied"
  }
}

run "custom_resource_names" {
  command = plan

  variables {
    vmss = {
      resource_group_name = "rg-test"
      subnet_name         = "subnet-test"
      sku                 = "Standard_D2s_v5"
      instances           = 1
      postfix             = "web"
      userDefinedString   = "myapp"

      overprovision          = true
      single_placement_group = true

      vmss_name = "existing-vmss-name"
      nic_name  = "existing-vmss-nic1"

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
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.vmss_linux.name == "existing-vmss-name"
    error_message = "vmss_name override must take priority over the generated name"
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.vmss_linux.network_interface[0].name == "existing-vmss-nic1"
    error_message = "nic_name override must take priority over the generated name"
  }
}

run "loadbalancer_floating_ip_enabled_new_key" {
  command = plan

  variables {
    vmss = {
      resource_group_name = "rg-test"
      subnet_name         = "subnet-test"
      sku                 = "Standard_D2s_v5"
      instances           = 1
      postfix             = "lb1"
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

      lb = {
        sku = "Standard"
        probes = {
          tcp443 = { port = 443 }
        }
        rules = {
          tcp443 = {
            protocol            = "Tcp"
            frontend_port       = 443
            backend_port        = 443
            probe_name          = "tcp443"
            load_distribution   = "SourceIPProtocol"
            floating_ip_enabled = true
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_lb_rule.loadbalancer-lbr["tcp443"].floating_ip_enabled == true
    error_message = "floating_ip_enabled (azurerm >= 5.0 key) must be honoured"
  }
}

run "loadbalancer_floating_ip_enabled_legacy_key" {
  command = plan

  variables {
    vmss = {
      resource_group_name = "rg-test"
      subnet_name         = "subnet-test"
      sku                 = "Standard_D2s_v5"
      instances           = 1
      postfix             = "lb2"
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

      lb = {
        sku = "Standard"
        probes = {
          tcp443 = { port = 443 }
        }
        rules = {
          tcp443 = {
            protocol           = "Tcp"
            frontend_port      = 443
            backend_port       = 443
            probe_name         = "tcp443"
            load_distribution  = "SourceIPProtocol"
            enable_floating_ip = true # legacy azurerm < 5.0 key — must still work
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_lb_rule.loadbalancer-lbr["tcp443"].floating_ip_enabled == true
    error_message = "legacy enable_floating_ip key must still be honoured for backward compatibility"
  }
}

run "loadbalancer_floating_ip_omitted" {
  command = plan

  variables {
    vmss = {
      resource_group_name = "rg-test"
      subnet_name         = "subnet-test"
      sku                 = "Standard_D2s_v5"
      instances           = 1
      postfix             = "lb3"
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

      lb = {
        sku = "Standard"
        probes = {
          tcp443 = { port = 443 }
        }
        rules = {
          tcp443 = {
            protocol          = "Tcp"
            frontend_port     = 443
            backend_port      = 443
            probe_name        = "tcp443"
            load_distribution = "SourceIPProtocol"
            # floating_ip_enabled intentionally omitted — must not error
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_lb_rule.loadbalancer-lbr["tcp443"].floating_ip_enabled == false
    error_message = "floating_ip_enabled must default to false when neither key is supplied"
  }
}
