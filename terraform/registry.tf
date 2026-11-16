resource "azurerm_container_registry" "cr_01" {
  name                = "cr${local.compact_name}${local.suffix}"
  resource_group_name = azurerm_resource_group.rg_01.name
  location            = azurerm_resource_group.rg_01.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.tags
}