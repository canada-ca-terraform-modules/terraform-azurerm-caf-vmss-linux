locals {
  vmss_linux_regex     = "/[//\"'\\[\\]:|<>+=;,?*@&]/" # Can't include those characters in windows_virtual_machine name: \/"'[]:|<>+=;,?*@&
  env_4                = substr(var.env, 0, 4)
  serverType_3         = "SLG"
  postfix_3            = substr(var.vmss.postfix, 0, 3)
  userDefinedString_54 = substr(var.vmss.userDefinedString, 0, 54 - length(local.postfix_3))
  vmss_name            = try(var.vmss.custom_name, replace("${local.env_4}${local.serverType_3}-${local.userDefinedString_54}${local.postfix_3}", local.vmss_linux_regex, ""))

  # Optional overrides for every auto-generated resource name below. Callers whose real infra
  # names diverge from the naming formula can pin them here without forcing a destroy/recreate.
  # coalesce() is used so that an explicit null value falls back to the generated name, just
  # like an absent key would.
  vmss_resource_name   = coalesce(try(var.vmss.vmss_name, null), "${local.vmss_name}-vmss")
  nic_name             = coalesce(try(var.vmss.nic_name, null), "${local.vmss_name}-nic1")
  lb_name              = coalesce(try(var.vmss.lb.name, null), "${local.vmss_name}-lb")
  lb_frontend_name     = coalesce(try(var.vmss.lb.frontend_name, null), "${local.vmss_name}-lbfe")
  lb_backend_pool_name = coalesce(try(var.vmss.lb.backend_pool_name, null), "${local.vmss_name}-HA-lbbp")
}
