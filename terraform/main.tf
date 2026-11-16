resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_storage_share" "images" {
  name               = "images"
  storage_account_id = azurerm_storage_account.sa_01.id
  quota              = 1
}

resource "azurerm_storage_share_file" "sample_image" {
  name              = "sample.svg"
  storage_share_url = azurerm_storage_share.images.url
  source            = "${path.module}/../src/AzureContainerApps.Api/Assets/sample.svg"
  content_type      = "image/svg+xml"

  depends_on = [azurerm_role_assignment.terraform_files_data_contributor]
}

resource "azurerm_role_assignment" "terraform_files_data_contributor" {
  scope                = azurerm_storage_share.images.rbac_scope_id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "storage_file_reader" {
  scope                = azurerm_storage_share.images.rbac_scope_id
  role_definition_name = "Storage File Data Privileged Reader"
  principal_id         = azurerm_user_assigned_identity.uai_01.principal_id
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.cr_01.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.uai_01.principal_id
}