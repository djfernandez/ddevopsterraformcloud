resource "azurerm_container_app_environment" "cae_01" {
  name                = "cae-${var.project_name}-${var.environment}-${var.location}"
  location            = azurerm_resource_group.rg_01.location
  resource_group_name = azurerm_resource_group.rg_01.name
  tags                = local.tags
}

resource "azurerm_container_app" "ca_01" {
  name                         = "ca-${var.project_name}-${var.environment}-${var.location}"
  resource_group_name          = azurerm_resource_group.rg_01.name
  container_app_environment_id = azurerm_container_app_environment.cae_01.id
  revision_mode                = "Single"
  tags                         = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai_01.id]
  }

  registry {
    server   = azurerm_container_registry.cr_01.login_server
    identity = azurerm_user_assigned_identity.uai_01.id
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
        value = azurerm_user_assigned_identity.uai_01.client_id
      }
      env {
        name  = "KEY_VAULT_URI"
        value = azurerm_key_vault.kv_01.vault_uri
      }
      env {
        name  = "KEY_VAULT_SECRET_NAME"
        value = var.key_vault_secret_name
      }
      env {
        name  = "STORAGE_FILE_ENDPOINT"
        value = azurerm_storage_account.sa_01.primary_file_endpoint
      }
      env {
        name  = "FILE_SHARE_NAME"
        value = azurerm_storage_share.ss_01.name
      }
      env {
        name  = "FILE_NAME"
        value = azurerm_storage_share_file.sample_image.name
      }
    }

    http_scale_rule {
      name                = "http-requests"
      concurrent_requests = "50"
    }
  }

  depends_on = [
    azurerm_role_assignment.identity_kv_secrets,
    azurerm_role_assignment.identity_kv_secrets_02,
    azurerm_role_assignment.acr_pull,
    azurerm_role_assignment.storage_file_reader
  ]
}