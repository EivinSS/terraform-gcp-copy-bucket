import base64
import os
from google.cloud import storage
from datetime import datetime

def hello_pubsub(event, context):

     # Creates a timestamp: yyyymmdd_hh:mm:ss
     now = datetime.now()
     timestamp = now.strftime("%Y%m%d_%H:%M:%S")

     storage_client = storage.Client()
     # Define the origin bucket
     origin = storage_client.bucket(os.environ['SOURCE_BUCKET'])
     # Define the destination bucket
     destination = storage_client.bucket(os.environ['SINK_BUCKET'])
     # Get the list of the blobs located inside the bucket which files you want to copy
     blobs = storage_client.list_blobs(os.environ['SOURCE_BUCKET'])

     for blob in blobs:
          # Copies the blobs to the destionation
          origin.copy_blob(blob, destination)
          # Making a temporary blob referenceing the blob just copied
          tempBlob = destination.blob(blob.name)
          # Renaming the blob. By doing so we change the path inside the timestamp-folder
          destination.rename_blob(tempBlob, timestamp + '/' + tempBlob.name)
          
     return "Done!"