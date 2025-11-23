import os
import boto3
import logging

logger = logging.getLogger(__name__)


class Settings:
    
    def __init__(self):
        self.user_pool_id = os.environ.get('USER_POOL_ID')
        self.client_id = os.environ.get('CLIENT_ID')
        self.jwt_secret = self._get_jwt_secret()
        
        if not self.user_pool_id:
            raise ValueError("USER_POOL_ID environment variable is required")
    
    def _get_jwt_secret(self) -> str:
        try:
            ssm = boto3.client('ssm')
            response = ssm.get_parameter(
                Name='/tech-challenge/jwt-secret',
                WithDecryption=True
            )
            return response['Parameter']['Value']
        except Exception as e:
            logger.error(f"Erro ao buscar JWT_SECRET: {str(e)}")
            return os.environ.get('JWT_SECRET', 'fallback-secret-dev-only')


settings = Settings()
