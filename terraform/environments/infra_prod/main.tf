module "billing_records_solution" {
  source = "../../project"
  
  resource_group_name          = "rg-billing-prod"
  location                     = "eastus"
  function_storage_account_name = "fnbillingprodstorage"
  archive_storage_account_name  = "archivebillingprodstorage"
  archive_container_name        = "archived-billing-records"
  cosmos_account_name           = "cosmos-billing-prod"
  cosmos_db_name                = "billing-db"
  cosmos_container_name         = "billing-records"
  app_service_plan_name         = "billing-prod-asp"
  function_app_name             = "billing-records-prod-function"
  
  tags = {
    Environment = "prod"
    Project     = "BillingRecordsCostOptimization"
  }
}