import logging
from drivers.lambda_adapter import LambdaAdapter

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    adapter = LambdaAdapter()
    return adapter.handle(event, context)