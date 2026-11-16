resource "azurerm_key_vault" "kv_01" {
  name                       = "kv-${local.compact_name}-${local.suffix}"
  location                   = azurerm_resource_group.rg_01.location
  resource_group_name        = azurerm_resource_group.rg_01.name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  tags                       = local.tags
}