output "registry_url" {
  value = azurerm_container_registry.acr.login_server
}

output "registry_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "registry_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}

output "acr_id" {
  value = azurerm_container_registry.acr.id
}