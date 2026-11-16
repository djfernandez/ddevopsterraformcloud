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

resource "azurerm_storage_share" "ss_01" {
  name               = "ss${local.compact_name}${local.suffix}-${var.environment}-${var.location}"
  storage_account_id = azurerm_storage_account.sa_01.id
  quota              = 1
}

resource "azurerm_storage_share_file" "sample_image" {
  name              = "sample.svg"
  storage_share_url = azurerm_storage_share.ss_01.url
  source            = "${path.module}/../src/AzureContainerApps.Api/Assets/sample.svg"
  content_type      = "image/svg+xml"

  depends_on = [azurerm_role_assignment.terraform_files_data_contributor]
}

resource "azurerm_role_assignment" "terraform_files_data_contributor" {
  scope                = azurerm_storage_share.ss_01.rbac_scope_id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "storage_file_reader" {
  scope                = azurerm_storage_share.ss_01.rbac_scope_id
  role_definition_name = "Storage File Data Privileged Reader"
  principal_id         = azurerm_user_assigned_identity.uai_01.principal_id
}