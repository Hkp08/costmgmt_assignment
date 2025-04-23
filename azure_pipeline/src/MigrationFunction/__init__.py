import json
import logging
import os
import datetime
from dateutil.relativedelta import relativedelta
import azure.functions as func
from azure.cosmos import CosmosClient
from azure.storage.blob import BlobServiceClient, ContentSettings
from azure.identity import DefaultAzureCredential

# Configuration - would be stored in app settings in production
COSMOS_DB_ENDPOINT = os.environ["COSMOS_DB_ENDPOINT"]
COSMOS_DB_KEY = os.environ["COSMOS_DB_KEY"]
COSMOS_DB_DATABASE = os.environ["COSMOS_DB_DATABASE"]
COSMOS_DB_CONTAINER = os.environ["COSMOS_DB_CONTAINER"]
STORAGE_ACCOUNT_NAME = os.environ["STORAGE_ACCOUNT_NAME"]
STORAGE_CONTAINER_NAME = os.environ["STORAGE_CONTAINER_NAME"]
MIGRATION_THRESHOLD_MONTHS = int(os.environ.get("MIGRATION_THRESHOLD_MONTHS", "3"))

def main(timer: func.TimerRequest, context: func.Context) -> None:
    """Main function triggered by timer to migrate records older than threshold"""
    logging.info('Record migration timer trigger function started')
    
    try:
        # Initialize clients
        cosmos_client = CosmosClient(COSMOS_DB_ENDPOINT, credential=COSMOS_DB_KEY)
        blob_service_client = BlobServiceClient(
            account_url=f"https://{STORAGE_ACCOUNT_NAME}.blob.core.windows.net",
            credential=DefaultAzureCredential()
        )
        blob_container_client = blob_service_client.get_container_client(STORAGE_CONTAINER_NAME)

        # Initialize database and container
        database = cosmos_client.get_database_client(COSMOS_DB_DATABASE)
        container = database.get_container_client(COSMOS_DB_CONTAINER)
        
        threshold_date = datetime.datetime.utcnow() - relativedelta(months=MIGRATION_THRESHOLD_MONTHS)
        threshold_date_str = threshold_date.strftime('%Y-%m-%dT%H:%M:%SZ')
        
        # Query for records older than threshold
        query = f"SELECT * FROM c WHERE c.createdAt < '{threshold_date_str}'"
        
        items = list(container.query_items(
            query=query,
            enable_cross_partition_query=True
        ))
        
        logging.info(f"Found {len(items)} records to migrate")
        
        # Process records in batches
        for item in items:
            # Create blob name from record ID
            blob_name = f"{item['id']}.json"
            
            # Check if already migrated
            if not blob_exists(blob_container_client, blob_name):
                # Add metadata to indicate this record has been archived
                item['archived'] = True
                item['archivedAt'] = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
                
                # Upload to blob storage
                blob_client = blob_container_client.get_blob_client(blob_name)
                blob_client.upload_blob(
                    json.dumps(item),
                    overwrite=True,
                    content_settings=ContentSettings(content_type='application/json')
                )
                
                # Delete from Cosmos DB
                container.delete_item(item=item['id'], partition_key=item.get('partitionKey', item['id']))
                
                logging.info(f"Migrated record {item['id']} to cold storage")
        
        logging.info("Migration completed successfully")
    
    except Exception as e:
        logging.error(f"Error during migration: {str(e)}")
        raise

def blob_exists(container_client, blob_name):
    """Check if a blob exists in storage"""
    try:
        blob_client = container_client.get_blob_client(blob_name)
        return blob_client.exists()
    except Exception:
        return False