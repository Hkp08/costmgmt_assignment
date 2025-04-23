variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "function_storage_account_name" {
  description = "The name of the Function App storage account"
  type        = string
}

variable "archive_storage_account_name" {
  description = "The name of the archive storage account"
  type        = string
}

variable "archive_container_name" {
  description = "The name of the archive container"
  type        = string
  default     = "archived-billing-records"
}

variable "cosmos_account_name" {
  description = "The name of the Cosmos DB account"
  type        = string
}

variable "cosmos_db_name" {
  description = "The name of the Cosmos DB database"
  type        = string
  default     = "billing-db"
}

variable "cosmos_container_name" {
  description = "The name of the Cosmos DB container"
  type        = string
  default     = "billing-records"
}

variable "app_service_plan_name" {
  description = "The name of the App Service Plan"
  type        = string
}

variable "function_app_name" {
  description = "The name of the Function App"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "BillingRecordsCostOptimization"
  }
}