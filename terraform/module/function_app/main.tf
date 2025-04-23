resource "azurerm_service_plan" "function_app_plan" {
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "Y1" # Consumption plan for serverless

  tags = var.tags
}

resource "azurerm_application_insights" "function_app_insights" {
  name                = "${var.function_app_name}-insights"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
  
  tags = var.tags
}

resource "azurerm_function_app" "function_app" {
  name                       = var.function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_service_plan.function_app_plan.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_key
  version                    = "~4"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "python"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.function_app_insights.instrumentation_key
    "COSMOS_DB_ENDPOINT"             = var.cosmos_db_endpoint
    "COSMOS_DB_KEY"                  = var.cosmos_db_key
    "COSMOS_DB_DATABASE"             = var.cosmos_db_name
    "COSMOS_DB_CONTAINER"            = var.cosmos_container_name
    "STORAGE_ACCOUNT_NAME"           = var.archive_storage_account_name
    "STORAGE_CONTAINER_NAME"         = var.archive_container_name
    "MIGRATION_THRESHOLD_MONTHS"     = "3"
  }

  site_config {
    cors {
      allowed_origins = ["*"]
    }
    use_32_bit_worker_process = false
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}