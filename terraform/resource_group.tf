resource "azurerm_resource_group" "rq_01" {
  name     = "rg-${var.project_name}-${var.environment}-${var.location}"
  location = var.location
  tags     = local.tags
}