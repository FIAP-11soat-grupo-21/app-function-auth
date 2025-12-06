import jwt
import uuid
import logging
from typing import Optional

from domain.entities.user import User
from domain.ports.token_service import TokenServiceInterface

logger = logging.getLogger(__name__)


class JWTTokenService(TokenServiceInterface):
    
    def __init__(self, secret_key: str):
        self.secret_key = secret_key
        self.algorithm = "HS256"
    
    def generate_token(self, user: User) -> str:
        try:
            payload = {
                "cpf": user.cpf,
                "name": user.name,
                "email": user.email,
                "type": "authenticated"
            }
            return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
        except Exception as e:
            logger.error(f"Erro ao gerar token para usuário {user.cpf}: {e}")
            raise Exception(f"Erro ao gerar token: {str(e)}")
    
    def generate_anonymous_token(self) -> str:
        try:
            anonymous_id = str(uuid.uuid4())
            payload = {
                "username": anonymous_id,
                "type": "anonymous"
            }
            return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
        except Exception as e:
            logger.error(f"Erro ao gerar token anônimo: {e}")
            raise Exception(f"Erro ao gerar token anônimo: {str(e)}")
    
    def validate_token(self, token: str) -> Optional[dict]:
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            return payload
        except jwt.ExpiredSignatureError:
            logger.warning("Token expirado")
            return None
        except jwt.InvalidTokenError:
            logger.warning("Token inválido")
            return None
        except Exception as e:
            logger.error(f"Erro ao validar token: {e}")
            return None
