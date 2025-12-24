import json
import logging
from typing import Dict, Any

from drivers.auth_controller import AuthController
from application.auth_service import AuthServiceFactory

logger = logging.getLogger(__name__)


class LambdaAdapter:
    def handle(self, event: Dict[str, Any], context: Any) -> Dict[str, Any]:
        try:
            auth_service = AuthServiceFactory.create()
            controller = AuthController(auth_service)
            return controller.handle_request(event)
        except Exception as e:
            logger.error(f"Erro inesperado na Lambda: {str(e)}")
            return {
                "statusCode": 500,
                "body": json.dumps({"message": f"Erro inesperado: {str(e)}"})
            }
