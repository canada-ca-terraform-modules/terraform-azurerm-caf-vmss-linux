# test_dependencies.tf
# Self-contained dependency resources, owned entirely by this harness.
#
# Deliberately NOT reusing any shared/production resource group or vnet:
# writing into shared infra usually requires elevated, non-sandbox
# permissions. A dedicated throwaway RG + vnet + subnet here needs only
# Contributor on the sandbox subscription and can never collide with or
# affect any production resource.
#
# terraform-azurerm-caf-vmss-linux needs a resource group (keyed map,
# `var.resource_groups`) and a subnet (keyed map, `var.subnets`) - it
# doesn't consume a vnet directly, but the subnet has to live in one.

resource "azurerm_resource_group" "live_test" {
  # PR-number suffix keeps two concurrently open PRs against this module
  # from colliding on the same sandbox resource group.
  name     = "${var.env}-caf-vmss-linux-live-test-${var.pr_number}-rg"
  location = var.location

  # pr-number tag: lets the nightly orphan sweeper find this RG by tag and
  # match it back to a PR, independent of naming convention.
  # repository tag: the sandbox subscription is shared across module repos,
  # so the sweeper must scope its `pr-number` matches to only this repo's
  # own PRs - otherwise a PR number collision across repos could
  # misclassify (or destroy) another repo's live resource group.
  tags = merge(var.tags, {
    "pr-number"  = var.pr_number
    "repository" = var.repository
  })
}

resource "azurerm_virtual_network" "live_test" {
  name                = "${var.env}-caf-vmss-linux-live-test-${var.pr_number}-vnet"
  address_space       = ["10.252.0.0/16"] # arbitrary, unpeered - collision-safe by construction
  location            = azurerm_resource_group.live_test.location
  resource_group_name = azurerm_resource_group.live_test.name
  tags                = var.tags
}

resource "azurerm_subnet" "live_test" {
  name                 = "live-test-snet"
  resource_group_name  = azurerm_resource_group.live_test.name
  virtual_network_name = azurerm_virtual_network.live_test.name
  address_prefixes     = ["10.252.1.0/24"]
}

locals {
  # Keyed maps matching terraform-azurerm-caf-vmss-linux's expected shape:
  # var.resource_groups[var.vmss.resource_group_name].name
  # var.subnets[var.vmss.subnet_name].id
  resource_groups = { live_test = { name = azurerm_resource_group.live_test.name } }
  subnets         = { live_test = { id = azurerm_subnet.live_test.id } }
}

# terraform-azurerm-caf-vmss-linux's admin_password has no in-module fallback
# (unlike e.g. terraform-azurerm-caf-linux_virtual_machineV2's optional
# admin_password + random_password combo) - it's a required, sensitive
# input. Generated here instead of plumbed through as a new CI secret, so
# this harness needs no additional live-test environment configuration
# beyond the three standard OIDC secrets.
resource "random_password" "vmss_admin" {
  length      = 20
  special     = true
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}
