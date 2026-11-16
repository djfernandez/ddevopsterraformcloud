resource "azurerm_storage_account" "sa_01" {
  name                            = "st${local.compact_name}${local.suffix}"
  resource_group_name             = azurerm_resource_group.rg_01.name
  location                        = azurerm_resource_group.rg_01.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  tags                            = local.tags
}