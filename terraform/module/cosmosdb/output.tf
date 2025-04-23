output "cosmos_account_name" {
  description = "The name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos_account.name
}

output "cosmos_account_endpoint" {
  description = "The endpoint of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos_account.endpoint
}

output "cosmos_primary_key" {
  description = "The primary key of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos_account.primary_master_key
  sensitive   = true
}

output "cosmos_db_name" {
  description = "The name of the Cosmos DB database"
  value       = azurerm_cosmosdb_sql_database.cosmos_db.name
}

output "cosmos_container_name" {
  description = "The name of the Cosmos DB container"
  value       = azurerm_cosmosdb_sql_container.cosmos_container.name
}