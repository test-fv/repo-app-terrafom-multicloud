resource "azurerm_user_assigned_identity" "identity" {
  name                = "${var.name_prefix}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id

  role_definition_name = "AcrPull"

  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}