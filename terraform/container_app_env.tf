resource "azurerm_container_app_environment" "cae_01" {
  name                       = "env-${var.project_name}-${var.environment}-${var.location}"
  location                   = azurerm_resource_group.rq_01.location
  resource_group_name        = azurerm_resource_group.rq_01.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.tags
}

resource "azurerm_container_app" "ca_01" {
  name                         = "${var.project_name}-${var.environment}-api"
  resource_group_name          = azurerm_resource_group.rq_01.name
  container_app_environment_id = azurerm_container_app_environment.cae_01.id
  revision_mode                = "Single"
  tags                         = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  registry {
    server   = azurerm_container_registry.cr_01.login_server
    identity = azurerm_user_assigned_identity.app.id
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 1
    max_replicas = 3

    container {
      name   = "api"
      image  = var.container_image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "WELCOME_MESSAGE"
        value = "Hello from Terraform-managed Azure Container Apps"
      }
      env {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.app.client_id
      }
      env {
        name  = "KEY_VAULT_URI"
        value = azurerm_key_vault.main.vault_uri
      }
      env {
        name  = "KEY_VAULT_SECRET_NAME"
        value = var.key_vault_secret_name
      }
      env {
        name  = "STORAGE_FILE_ENDPOINT"
        value = azurerm_storage_account.main.primary_file_endpoint
      }
      env {
        name  = "FILE_SHARE_NAME"
        value = azurerm_storage_share.images.name
      }
      env {
        name  = "FILE_NAME"
        value = azurerm_storage_share_file.sample_image.name
      }
      env {
        name  = "SQL_SERVER_FQDN"
        value = azurerm_mssql_server.main.fully_qualified_domain_name
      }
      env {
        name  = "SQL_DATABASE"
        value = azurerm_mssql_database.main.name
      }
    }

    http_scale_rule {
      name                = "http-requests"
      concurrent_requests = "50"
    }
  }

  depends_on = [
    azurerm_role_assignment.key_vault_secrets_user,
    azurerm_role_assignment.storage_file_reader,
    azurerm_role_assignment.acr_pull
  ]
}