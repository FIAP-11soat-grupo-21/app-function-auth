import json
from typing import Any, Dict


class HttpResponse:
    @staticmethod
    def success(status_code: int, body: Any) -> Dict[str, Any]:
        return {
            "statusCode": status_code,
            "body": json.dumps(body)
        }

    @staticmethod
    def error(status_code: int, message: str) -> Dict[str, Any]:
        return {
            "statusCode": status_code,
            "body": json.dumps({"message": message})
        }

