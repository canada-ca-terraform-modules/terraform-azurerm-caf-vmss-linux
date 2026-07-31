# tests/upgrade_compat.tftest.hcl
# Purpose: catch breaking resource address changes before running against real infra.
# Applies a baseline config (representing what's already deployed pre-upgrade) then
# plans the same inputs again — if the upgraded code renamed a resource or changed an
# address without a `moved` block, this shows as a destroy+create instead of no-op/update.

mock_provider "azurerm" {}

variables {
  tags            = { environment = "test" }
  env             = "Dev"
  location        = "canadacentral"
  resource_groups = { rg-test = { name = "rg-test", location = "canadacentral" } }
  subnets         = { subnet-test = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test" } }
  admin_password  = "P@ssw0rd-Test-1234!"

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
          enable_floating_ip = true # simulates a config written before the azurerm 5.0 upgrade
        }
      }
    }
  }
}

# Step 1: simulate the currently-deployed resource (pre-upgrade inputs, legacy key).
run "baseline_apply" {
  command = apply

  # mock_provider generates an opaque id for azurerm_lb by default, which fails
  # the ARM-ID-format validation performed by azurerm_lb_probe/backend_address_pool
  # when they parse `loadbalancer_id`. Override it with a realistic ARM ID.
  override_resource {
    target = azurerm_lb.loadbalancer[0]
    values = {
      id = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/loadBalancers/DevSLG-myappweb-lb"
    }
  }

  override_resource {
    target = azurerm_lb_backend_address_pool.loadbalancer-lbbp[0]
    values = {
      id = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/loadBalancers/DevSLG-myappweb-lb/backendAddressPools/DevSLG-myappweb-HA-lbbp"
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.vmss_linux.name == "DevSLG-myappweb-vmss"
    error_message = "Baseline apply: unexpected VMSS name"
  }
  assert {
    condition     = azurerm_lb_rule.loadbalancer-lbr["tcp443"].floating_ip_enabled == true
    error_message = "Baseline apply: floating_ip_enabled must be true"
  }
}

# Step 2: plan the upgraded code against that same state with unchanged inputs.
run "upgrade_plan_no_replacement" {
  command = plan

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.vmss_linux.name == "DevSLG-myappweb-vmss"
    error_message = "VMSS name must be unchanged after upgrade — a rename here means missing `moved` blocks"
  }
  assert {
    condition     = azurerm_lb.loadbalancer[0].name == "DevSLG-myappweb-lb"
    error_message = "Load balancer name must be unchanged after upgrade"
  }
  assert {
    condition     = azurerm_lb_rule.loadbalancer-lbr["tcp443"].floating_ip_enabled == true
    error_message = "floating_ip_enabled must still resolve to true via the legacy enable_floating_ip key"
  }
}
