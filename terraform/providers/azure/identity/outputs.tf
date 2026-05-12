# outputs.tf for identity
output "identity_id" {
  value = azurerm_user_assigned_identity.identity.id
}