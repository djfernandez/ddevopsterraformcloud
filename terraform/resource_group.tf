resource "azurerm_resource_group" "rg_01" {
  name     = "rg-${var.project_name}-${var.environment}-${var.location}"
  location = var.location
  tags     = local.tags
}

# import {
#   to = azurerm_resource_group.rg_01
#   id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-${var.project_name}-${var.environment}-${var.location}"
# }