from domain.entities.user import AuthResult
from domain.ports.token_service import TokenServiceInterface

class CreateAnonymousUserUseCase:
    def __init__(self, token_service: TokenServiceInterface):
        self.token_service = token_service

    def execute(self) -> AuthResult:
        try:
            token = self.token_service.generate_anonymous_token()
            return AuthResult(
                success=True,
                token=token,
                message="Usuário anônimo criado com sucesso",
                user=None
            )
        except Exception as e:
            return AuthResult(
                success=False,
                message=str(e),
                token=None,
                user=None
            )   
        
