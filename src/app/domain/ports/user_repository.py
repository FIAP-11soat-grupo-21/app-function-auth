from abc import ABC, abstractmethod
from typing import Optional
from domain.entities.user import User

class UserRepositoryInterface(ABC):
    @abstractmethod
    def find_by_cpf(self, cpf: str) -> Optional[User]:       
        pass    

    @abstractmethod
    def save(self, user: User) -> User:
        pass

    @abstractmethod
    def user_exists(self, cpf: str) -> bool:
        pass
