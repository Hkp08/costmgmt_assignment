output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.archive_storage.name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.archive_storage.id
}

output "container_name" {
  description = "The name of the storage container"
  value       = azurerm_storage_container.archive_container.name
}