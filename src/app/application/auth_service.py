from domain.use_cases.register_user import RegisterUseCase
from domain.use_cases.find_user_by_cpf import FindUserByCPFUseCase
from domain.use_cases.create_anonymous_user import CreateAnonymousUserUseCase
from domain.ports.user_repository import UserRepositoryInterface
from domain.ports.token_service import TokenServiceInterface

class AuthService:    
    def __init__(self, user_repository: UserRepositoryInterface, token_service: TokenServiceInterface):
        self._register_use_case = RegisterUseCase(user_repository, token_service)
        self._find_user_use_case = FindUserByCPFUseCase(user_repository, token_service)
        self._anonymous_use_case = CreateAnonymousUserUseCase(token_service)
    
    def register_user(self, cpf: str, name: str, email: str):
        return self._register_use_case.execute(cpf, name, email)
    
    def find_user_by_cpf(self, cpf: str):
        return self._find_user_use_case.execute(cpf)
    
    def create_anonymous_user(self):
        return self._anonymous_use_case.execute()


class AuthServiceFactory:
    
    @staticmethod
    def create() -> AuthService:
        from driven.adapters.cognito_user_repository import CognitoUserRepository
        from driven.adapters.jwt_token_service import JWTTokenService
        from driven.config.settings import settings
        
        user_repository = CognitoUserRepository(settings.user_pool_id, settings.client_id)
        token_service = JWTTokenService(settings.jwt_secret)
        
        return AuthService(user_repository, token_service)
