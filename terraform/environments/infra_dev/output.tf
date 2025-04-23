output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.billing_records_solution.resource_group_name
}

output "cosmos_db_endpoint" {
  description = "The endpoint of the Cosmos DB account"
  value       = module.billing_records_solution.cosmos_db_endpoint
}

output "function_app_hostname" {
  description = "The hostname of the function app"
  value       = module.billing_records_solution.function_app_hostname
}