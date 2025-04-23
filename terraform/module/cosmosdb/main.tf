resource "azurerm_cosmosdb_account" "cosmos_account" {
  name                = var.cosmos_account_name
  resource_group_name = var.resource_group_name
  location            = var.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "cosmos_db" {
  name                = var.cosmos_db_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
}

resource "azurerm_cosmosdb_sql_container" "cosmos_container" {
  name                = var.cosmos_container_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
  database_name       = azurerm_cosmosdb_sql_database.cosmos_db.name
  partition_key_path  = "/id"
  
  # Set TTL to auto-expire documents (optional)
  # default_ttl        = 7776000 # 90 days in seconds
  
  indexing_policy {
    indexing_mode = "consistent"
    
    included_path {
      path = "/*"
    }
    
    excluded_path {
      path = "/\"_etag\"/?"
    }
  }
}