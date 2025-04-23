resource "azurerm_storage_account" "archive_storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  
  # Enable hierarchical namespace for better performance
  is_hns_enabled           = true
  
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
  
  tags = var.tags
}

resource "azurerm_storage_container" "archive_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.archive_storage.name
  container_access_type = "private"
}