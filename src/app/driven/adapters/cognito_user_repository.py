import boto3
import logging
from typing import Optional
from botocore.exceptions import ClientError

from domain.entities.user import User
from domain.ports.user_repository import UserRepositoryInterface

logger = logging.getLogger(__name__)


class CognitoUserRepository(UserRepositoryInterface):
    
    def __init__(self, user_pool_id: str, client_id: str = None):
        self.user_pool_id = user_pool_id
        self.client_id = client_id
        self.cognito = boto3.client('cognito-idp')
    
    def find_by_cpf(self, cpf: str) -> Optional[User]:
        try:
            response = self.cognito.admin_get_user(
                UserPoolId=self.user_pool_id,
                Username=cpf
            )
            
            attributes = {attr["Name"]: attr["Value"] for attr in response.get("UserAttributes", [])}
            
            return User(
                cpf=cpf,
                name=attributes.get("name", ""),
                email=attributes.get("email", ""),
                id=response.get("Username")
            )
        except ClientError as e:
            if e.response['Error']['Code'] == 'UserNotFoundException':
                return None
            logger.error(f"Erro ao buscar usuário {cpf}: {e}")
            raise Exception(f"Erro ao buscar usuário: {str(e)}")
    
    def save(self, user: User) -> User:
        try:
            self.cognito.admin_create_user(
                UserPoolId=self.user_pool_id,
                Username=user.cpf,
                UserAttributes=[
                    {"Name": "name", "Value": user.name},
                    {"Name": "email", "Value": user.email}
                ],
                MessageAction="SUPPRESS"
            )
            
            user.id = user.cpf
            return user
        except ClientError as e:
            logger.error(f"Erro ao salvar usuário {user.cpf}: {e}")
            raise Exception(f"Erro ao salvar usuário: {str(e)}")
    
    def user_exists(self, cpf: str) -> bool:
        try:
            self.cognito.admin_get_user(
                UserPoolId=self.user_pool_id,
                Username=cpf
            )
            return True
        except ClientError as e:
            if e.response['Error']['Code'] == 'UserNotFoundException':
                return False
            logger.error(f"Erro ao verificar usuário {cpf}: {e}")
            raise Exception(f"Erro ao verificar usuário: {str(e)}")
