provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create a storage account for function app
resource "azurerm_storage_account" "function_storage" {
  name                     = var.function_storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = var.tags
}

# Create archive storage module
module "archive_storage" {
  source              = "../modules/storage"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  storage_account_name = var.archive_storage_account_name
  container_name      = var.archive_container_name
  tags                = var.tags
}

# Create cosmos db module
module "cosmos_db" {
  source              = "../modules/cosmos"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cosmos_account_name = var.cosmos_account_name
  cosmos_db_name      = var.cosmos_db_name
  cosmos_container_name = var.cosmos_container_name
  tags                = var.tags
}

# Create function app module
module "function_app" {
  source                     = "../modules/function"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  app_service_plan_name      = var.app_service_plan_name
  function_app_name          = var.function_app_name
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_key        = azurerm_storage_account.function_storage.primary_access_key
  cosmos_db_endpoint         = module.cosmos_db.cosmos_account_endpoint
  cosmos_db_key              = module.cosmos_db.cosmos_primary_key
  cosmos_db_name             = module.cosmos_db.cosmos_db_name
  cosmos_container_name      = module.cosmos_db.cosmos_container_name
  archive_storage_account_name = module.archive_storage.storage_account_name
  archive_container_name     = module.archive_storage.container_name
  tags                       = var.tags
}

# Assign the function app's managed identity to the archive storage blob data contributor role
resource "azurerm_role_assignment" "function_storage_blob_contributor" {
  scope                = module.archive_storage.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.function_app.function_app_principal_id
}
