from dataclasses import dataclass
from typing import Optional


@dataclass
class User:
    cpf: str
    name: str
    email: str
    id: Optional[str] = None
    
    def __post_init__(self):
        if not self.cpf or len(self.cpf) != 11:
            raise ValueError("CPF deve ter 11 dígitos")
        
        if not self.name or len(self.name.strip()) == 0:
            raise ValueError("Nome é obrigatório")
        
        if not self.email or "@" not in self.email:
            raise ValueError("Email inválido")


@dataclass
class AuthResult:
    success: bool
    token: Optional[str] = None
    message: Optional[str] = None
    user: Optional[User] = None
