import re

class ValidationError(Exception):
    def __init__(self, message: str):
        self.message = message
        super().__init__(message)

class RequestValidator:
    @staticmethod
    def validate_register_data(cpf: str, name: str, email: str) -> None:
        errors = []
        
        if not cpf or not cpf.strip():
            errors.append("CPF é obrigatório")
        elif not RequestValidator._is_valid_cpf_format(cpf):
            errors.append("CPF deve ter formato válido")
            
        if not name or not name.strip():
            errors.append("Nome é obrigatório")
        elif len(name.strip()) < 2:
            errors.append("Nome deve ter pelo menos 2 caracteres")
            
        if not email or not email.strip():
            errors.append("E-mail é obrigatório")
        elif not RequestValidator._is_valid_email(email):
            errors.append("E-mail deve ter formato válido")
        
        if errors:
            raise ValidationError("; ".join(errors))
    
    @staticmethod
    def validate_cpf(cpf: str) -> None:
        if not cpf or not cpf.strip():
            raise ValidationError("CPF é obrigatório")
        elif not RequestValidator._is_valid_cpf_format(cpf):
            raise ValidationError("CPF deve ter formato válido")
    
    @staticmethod
    def _is_valid_cpf_format(cpf: str) -> bool:
        cpf = re.sub(r'[^0-9]', '', cpf)
        return len(cpf) == 11
    
    @staticmethod
    def _is_valid_email(email: str) -> bool:
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))
