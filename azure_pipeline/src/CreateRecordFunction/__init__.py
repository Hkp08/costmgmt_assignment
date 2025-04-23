import json
import logging
import os
import datetime
import uuid
import azure.functions as func
from azure.cosmos import CosmosClient

# Configuration - would be stored in app settings in production
COSMOS_DB_ENDPOINT = os.environ["COSMOS_DB_ENDPOINT"]
COSMOS_DB_KEY = os.environ["COSMOS_DB_KEY"]
COSMOS_DB_DATABASE = os.environ["COSMOS_DB_DATABASE"]
COSMOS_DB_CONTAINER = os.environ["COSMOS_DB_CONTAINER"]

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request for record creation')
    
    try:
        # Initialize Cosmos DB client
        cosmos_client = CosmosClient(COSMOS_DB_ENDPOINT, credential=COSMOS_DB_KEY)
        database = cosmos_client.get_database_client(COSMOS_DB_DATABASE)
        container = database.get_container_client(COSMOS_DB_CONTAINER)
        
        # Get the request body
        try:
            req_body = req.get_json()
        except ValueError:
            return func.HttpResponse(
                "Invalid request body - JSON expected",
                status_code=400
            )
        
        # Ensure record has an ID
        if 'id' not in req_body:
            req_body['id'] = str(uuid.uuid4())
        
        # Add creation timestamp
        req_body['createdAt'] = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
        
        # Create the item in Cosmos DB
        container.create_item(body=req_body)
        
        return func.HttpResponse(
            json.dumps({"id": req_body['id'], "status": "created"}),
            mimetype="application/json",
            status_code=201
        )
    
    except Exception as e:
        logging.error(f"Error creating record: {str(e)}")
        return func.HttpResponse(
            "An error occurred while creating the record",
            status_code=500
        )