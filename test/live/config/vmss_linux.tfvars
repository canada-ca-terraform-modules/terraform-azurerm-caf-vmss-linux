# config/vmss_linux.tfvars
# Tracked, ready-to-run fixture for the test/live harness - one representative
# real-usage instance, not a two-code-path engineered fixture and not a
# dormant "_" template.
#
# Exercises the load balancer + lb_rule resources, including the azurerm 5.0
# floating_ip_enabled key (the module also accepts the legacy
# enable_floating_ip alias - see loadbalancer.tf).
#
# Maintained by whoever adds a new optional input to the module: update this
# file in the same PR if you want live coverage of it, same discipline as
# updating tests/vmss_linux.tftest.hcl.

env = "livetest"

vmss = {
  resource_group_name = "live_test"        # key from local.resource_groups (test_dependencies.tf)
  subnet_name         = "live_test"        # key from local.subnets (test_dependencies.tf)
  sku                 = "Standard_D2as_v6" # Dav6 family - see sandbox quota note in AGENTS/skill docs
  instances           = 1
  postfix             = "01"
  userDefinedString   = "livetest"

  overprovision          = true
  single_placement_group = true

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk = {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  lb = {
    sku                           = "Standard"
    private_ip_address_allocation = "Dynamic"

    probes = {
      tcp443 = {
        port                = 443
        interval_in_seconds = 5
      }
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
