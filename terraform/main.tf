resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "logs-${var.project_name}-${var.environment}-${var.location}"
  location            = azurerm_resource_group.rq_01.location
  resource_group_name = azurerm_resource_group.rq_01.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "identity-${var.project_name}-${var.environment}-${var.location}"
  location            = azurerm_resource_group.rq_01.location
  resource_group_name = azurerm_resource_group.rq_01.name
  tags                = local.tags
}

resource "azurerm_key_vault" "main" {
  name                       = "${local.compact_name}-${local.suffix}"
  location                   = azurerm_resource_group.rq_01.location
  resource_group_name        = azurerm_resource_group.rq_01.name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  tags                       = local.tags
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

resource "azurerm_storage_account" "main" {
  name                            = "${local.compact_name}${local.suffix}"
  resource_group_name             = azurerm_resource_group.rq_01.name
  location                        = azurerm_resource_group.rq_01.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  tags                            = local.tags
}

resource "azurerm_storage_share" "images" {
  name               = "images"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 1
}

resource "azurerm_storage_share_file" "sample_image" {
  name              = "sample.svg"
  storage_share_url = azurerm_storage_share.images.url
  source            = "${path.module}/../src/AzureContainerApps.Api/Assets/sample.svg"
  content_type      = "image/svg+xml"

  depends_on = [azurerm_role_assignment.terraform_files_data_contributor]
}

resource "azurerm_role_assignment" "storage_file_reader" {
  scope                = azurerm_storage_share.images.rbac_scope_id
  role_definition_name = "Storage File Data Privileged Reader"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

resource "azurerm_role_assignment" "terraform_files_data_contributor" {
  scope                = azurerm_storage_share.images.rbac_scope_id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_mssql_server" "main" {
  name                          = "${local.compact_name}-${local.suffix}-sql"
  resource_group_name           = azurerm_resource_group.rq_01.name
  location                      = azurerm_resource_group.rq_01.location
  version                       = "12.0"
  administrator_login           = var.sql_admin_username
  administrator_login_password  = var.sql_admin_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true
  tags                          = local.tags

  azuread_administrator {
    login_username              = var.sql_aad_admin_login_username
    object_id                   = var.sql_aad_admin_object_id
    tenant_id                   = var.tenant_id
    azuread_authentication_only = true
  }
}

resource "azurerm_mssql_database" "main" {
  name           = "${var.project_name}-${var.environment}-db"
  server_id      = azurerm_mssql_server.main.id
  sku_name       = "Basic"
  max_size_gb    = 2
  zone_redundant = false
  tags           = local.tags
}

resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.cr_01.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
