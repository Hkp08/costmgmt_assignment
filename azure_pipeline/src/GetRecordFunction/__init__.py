import json
import logging
import os
import azure.functions as func
from azure.cosmos import CosmosClient
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential

# Configuration - would be stored in app settings in production
COSMOS_DB_ENDPOINT = os.environ["COSMOS_DB_ENDPOINT"]
COSMOS_DB_KEY = os.environ["COSMOS_DB_KEY"]
COSMOS_DB_DATABASE = os.environ["COSMOS_DB_DATABASE"]
COSMOS_DB_CONTAINER = os.environ["COSMOS_DB_CONTAINER"]
STORAGE_ACCOUNT_NAME = os.environ["STORAGE_ACCOUNT_NAME"]
STORAGE_CONTAINER_NAME = os.environ["STORAGE_CONTAINER_NAME"]

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request for record retrieval')
    
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
        
        record_id = req.route_params.get('id')
        if not record_id:
            return func.HttpResponse(
                "Please provide a record ID",
                status_code=400
            )
        
        # Try to get from Cosmos DB first
        try:
            item = container.read_item(item=record_id, partition_key=record_id)
            logging.info(f"Record {record_id} found in Cosmos DB")
            return func.HttpResponse(
                json.dumps(item),
                mimetype="application/json",
                status_code=200
            )
        except Exception as e:
            logging.info(f"Record not found in Cosmos DB: {str(e)}")
            
            # Try to get from blob storage
            blob_name = f"{record_id}.json"
            blob_client = blob_container_client.get_blob_client(blob_name)
            
            if blob_client.exists():
                blob_data = blob_client.download_blob().readall()
                record = json.loads(blob_data)
                logging.info(f"Record {record_id} retrieved from blob storage")
                return func.HttpResponse(
                    json.dumps(record),
                    mimetype="application/json",
                    status_code=200
                )
            else:
                return func.HttpResponse(
                    f"Record {record_id} not found",
                    status_code=404
                )
    
    except Exception as e:
        logging.error(f"Error retrieving record: {str(e)}")
        return func.HttpResponse(
            "An error occurred while retrieving the record",
            status_code=500
        )