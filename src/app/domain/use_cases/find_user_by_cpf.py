from domain.entities.user import User, AuthResult
from domain.ports.user_repository import UserRepositoryInterface
from domain.ports.token_service import TokenServiceInterface

class FindUserByCPFUseCase:
    def __init__(self, user_repository: UserRepositoryInterface, token_service: TokenServiceInterface):
        self.user_repository = user_repository
        self.token_service = token_service

    def execute(self, cpf: str) -> AuthResult:
        try:
            if not cpf or not cpf.strip():
                return AuthResult(
                    success=False,
                    message="CPF é obrigatório!"
                )
            
            cpf = cpf.strip()
            if len(cpf) != 11:
                return AuthResult(
                    success=False,
                    message="CPF deve ter 11 dígitos"
                )
            
            user = self.user_repository.find_by_cpf(cpf)
            if not user:
                return AuthResult(
                    success=False,
                    message="Usuário não encontrado"
                )
            
            token = self.token_service.generate_token(user)
            return AuthResult(
                success=True,
                user=user,
                token=token,
                message="Usuário encontrado!"
            )
        except ValueError as e:
            return AuthResult(
                success=False,
                message=str(e)
            )