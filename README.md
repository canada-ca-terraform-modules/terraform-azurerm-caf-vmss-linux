# terraform-azurerm-caf-vmss-linux

Deploys a Linux Virtual Machine Scale Set (Uniform orchestration mode), with an
optional internal Standard Load Balancer, following the SSC CAF naming
convention.

## Usage

### ESLZ module block (`ESLZ/vmss_linux.tf`)

```hcl
module "vmss_linux" {
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-vmss-linux?ref=v1.3.0"
  for_each = var.vmss_linux

  tags            = try(each.value.tags, var.tags)
  env             = var.env
  location        = try(each.value.location, var.location)
  resource_groups = var.resource_groups
  subnets         = var.subnets
  admin_password  = try(each.value.admin_password, var.admin_password)
  custom_data     = try(each.value.custom_data, var.custom_data)
  vmss            = each.value
}
```

### ESLZ tfvars pattern (`ESLZ/vmss_linux.tfvars`)

```hcl
vmss_linux = {
  app01 = {
    resource_group_name = "app-rg"
    subnet_name         = "app-subnet"
    sku                 = "Standard_D2s_v5"
    instances           = 2
    postfix             = "web"
    userDefinedString   = "myapp"

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
```

## azurerm >= 5.0 notes

* Load balancer rules accept the new `floating_ip_enabled` key. The legacy
  `enable_floating_ip` key (used by azurerm < 5.0) is still accepted for
  backward compatibility.
* `vmss_name`, `nic_name`, `lb.name`, `lb.frontend_name` and
  `lb.backend_pool_name` are optional overrides for the auto-generated
  resource names — use them to pin names for infrastructure whose real names
  diverge from the naming formula, without a destroy/recreate.

## Testing

```bash
terraform fmt -recursive && terraform init -backend=false && terraform validate && terraform test
```

## CI

GitHub Actions workflow at `.github/workflows/terraform-ci.yml` runs fmt, init,
validate, and test on every PR.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_lb.loadbalancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.loadbalancer-lbbp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.loadbalancer-lbhp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.loadbalancer-lbr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_linux_virtual_machine_scale_set.vmss_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The password for the local administrator account on the virtual machines | `string` | n/a | yes |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | Custom data for VM instances | `string` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | 4 characters defining the envrionment name prefix for the scale set | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure Location in which the scale set is deployed | `string` | n/a | yes |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | List of resource groups objets | `any` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnets objects | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that will be associated with the ressource | `map(string)` | n/a | yes |
| <a name="input_vmss"></a> [vmss](#input\_vmss) | Details about vmss config | `any` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
