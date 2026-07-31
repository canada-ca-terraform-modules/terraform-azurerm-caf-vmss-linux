# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

- Upgraded `azurerm` provider constraint to `~> 5.0` (target requested: `5.5.0`,
  which does not exist yet at the time of this upgrade — latest published
  release is `v5.0.1`; pinned to the `5.0` minor line so patch releases apply
  automatically).
- `azurerm_lb_rule.loadbalancer-lbr`: `enable_floating_ip` renamed by the
  provider to `floating_ip_enabled` in azurerm 5.0. The module now reads
  `floating_ip_enabled` first, falls back to the legacy `enable_floating_ip`
  key, then defaults to `false` — so existing `ESLZ/*.tfvars` continue to
  work unchanged even when neither key is supplied.
- Removed dead, commented-out `automatic_os_upgrade_policy` block from
  `module.tf` (referenced provider arguments removed in azurerm 5.0 and was
  never active).
- `admin_password` variable now marked `sensitive = true` to prevent the
  password from appearing in Terraform CLI output or plan diffs.
- `tags` variable now has `default = {}`, making it optional.
- `azurerm_lb.loadbalancer` now receives `tags = var.tags` for consistency
  with the VMSS resource.
- Name override locals (`vmss_resource_name`, `nic_name`, `lb_*`) now use
  `coalesce(try(override, null), generated)` so that an explicit `null` value
  falls back to the generated name, matching the behaviour of an absent key.

### Added

- `providers.tf` with `required_providers` pinning `azurerm ~> 5.0`.
- `.tflint.hcl` using `call_module_type = "local"`.
- Optional name overrides (`vmss_name`, `nic_name`, `lb.name`,
  `lb.frontend_name`, `lb.backend_pool_name`) for every auto-generated resource
  name, so callers can pin real infrastructure names without a
  destroy/recreate.
- `ESLZ/vmss_linux.tf` and `ESLZ/vmss_linux.tfvars` — module block and example
  tfvars for L2 blueprints (previously absent).
- `tests/vmss_linux.tftest.hcl` and `tests/upgrade_compat.tftest.hcl`.
  Added test case `loadbalancer_floating_ip_omitted` to verify the `false`
  default when neither `floating_ip_enabled` nor `enable_floating_ip` is set.
- `outputs.tf` exporting `vmss_id`, `vmss_name`, `lb_id`, and
  `lb_frontend_ip_address` so callers can chain the module's resources.
- `lifecycle.precondition` on the VMSS resource that enforces the Azure
  64-character name limit at plan time with a human-readable error message.
- `.github/workflows/terraform-ci.yml` running fmt/init/validate/test/tflint.
- `.gitignore` and `.gitattributes` (LF line endings).

### Known blockers

- Target version `azurerm 5.5.0` requested for this upgrade does not exist;
  proceeded against the latest available release, `5.0.1`. Re-run this
  upgrade against `5.5.0` once it is published to pick up any additional
  provider changes.

## [1.2.3] - prior releases

See git history for changes prior to this upgrade (`git log --oneline`).
