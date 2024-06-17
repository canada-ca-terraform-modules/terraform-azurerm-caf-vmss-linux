variable "vmss_linux" {
  type = any
  default = {}
}

locals {
  linux_vmss_list = {
    for x in var.vmss_linux :
    "SLG-${x.userDefinedString}${x.postfix}" => x
  }
}

module "vmss_linux" {
  for_each = local.linux_vmss_list
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-vmss-linux?ref=v1.2.0"
  # source = "/home/max/devops/modules/terraform-azurerm-caf-vmss-linux"

  location        = var.location
  subnets         = local.subnets
  resource_groups = local.resource_groups_L2
  tags            = var.tags
  env             = var.env
  vmss            = each.value
  admin_password  = try(each.value.admin_password, "")
  custom_data     = try(each.value.custom_data, false) != false ? base64encode(file("${path.cwd}/${each.value.custom_data}")) : null
}
