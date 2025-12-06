from domain.entities.user import User, AuthResult
from domain.ports.user_repository import UserRepositoryInterface
from domain.ports.token_service import TokenServiceInterface

class RegisterUseCase:
    def __init__(self, user_repository: UserRepositoryInterface, token_service: TokenServiceInterface):
        self.user_repository = user_repository
        self.token_service = token_service

    def execute(self, cpf: str, name: str, email: str) -> AuthResult:
        try:
            if self.user_repository.user_exists(cpf):
                return AuthResult(
                    success=False,
                    message="Usuário com este CPF já existe"
                )
            user = User(cpf=cpf, name=name, email=email)
            saved_user = self.user_repository.save(user)

            token = self.token_service.generate_token(saved_user)

            return AuthResult(
                success=True,
                user=saved_user,
                token=token,
                message="Usuário registrado com sucesso"
            )
        except ValueError as e:
            return AuthResult(
                success=False,
                message=str(e)
            )