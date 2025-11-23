from abc import ABC, abstractmethod
from typing import Optional
from domain.entities.user import User


class TokenServiceInterface(ABC):
    @abstractmethod
    def generate_token(self, user: User) -> str:
        pass

    @abstractmethod
    def generate_anonymous_token(self) -> str:
        pass

    @abstractmethod
    def validate_token(self, token: str) -> Optional[dict]:
        pass