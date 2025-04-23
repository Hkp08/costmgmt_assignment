module "billing_records_solution" {
  source = "../../costmgmt_asgn"
  
  resource_group_name          = "rg-billing-dev"
  location                     = "eastus"
  function_storage_account_name = "fnbillingdevstorage"
  archive_storage_account_name  = "archivebillingdevstorage"
  archive_container_name        = "archived-billing-records"
  cosmos_account_name           = "cosmos-billing-dev"
  cosmos_db_name                = "billing-db"
  cosmos_container_name         = "billing-records"
  app_service_plan_name         = "billing-dev-asp"
  function_app_name             = "billing-records-dev-function"
  
  tags = {
    Environment = "dev"
    Project     = "BillingRecordsCostOptimization"
  }
}