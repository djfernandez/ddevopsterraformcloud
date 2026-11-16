output "resource_group_name" {
  description = "Grupo de recursos que contiene la implementación."
  value       = azurerm_resource_group.rg_01.name
}

output "container_app_name" {
  description = "Nombre de la aplicación de contenedor de Azure."
  value       = azurerm_container_app.ca_01.name
}

output "container_app_url" {
  description = "URL pública HTTPS para la aplicación."
  value       = "https://${azurerm_container_app.ca_01.ingress[0].fqdn}"
}

output "acr_login_server" {
  description = "Servidor de inicio de sesión de Azure Container Registry."
  value       = azurerm_container_registry.cr_01.login_server
}

output "acr_name" {
  description = "Nombre del recurso del Registro de Contenedores de Azure."
  value       = azurerm_container_registry.cr_01.name
}

output "key_vault_name" {
  description = "Nombre del recurso de Key Vault."
  value       = azurerm_key_vault.kv_01.name
}

output "identity_name" {
  description = "Nombre de la identidad asignada por el usuario adjunta a la aplicación de contenedor."
  value       = azurerm_user_assigned_identity.uai_01.name
}
