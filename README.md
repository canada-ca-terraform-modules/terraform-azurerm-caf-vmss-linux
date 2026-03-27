# terraform-azurerm-caf-vmss-windows
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

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