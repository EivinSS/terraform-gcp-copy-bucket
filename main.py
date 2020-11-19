import os
from google.cloud import storage
from google.cloud import pubsub


def publish_message(event, context):
    """Triggered by a change to a Cloud Storage bucket.
    Args:
        event (dict): Event payload.
        context (google.cloud.functions.Context): Metadata for the event.
    """
    file = event
    
    publish_client = pubsub.PublisherClient()
    publish_options = pubsub.types.PublisherOptions(enable_message_ordering=True)

    topic = os.environ['topic']
    bucket_name = file['bucket']
    file_name = file['name']

    publish_client.publish(topic, b'default-message', bucketName=f'{bucket_name}', fileName=f'{file_name}')

    return "done"

    #sdaasd