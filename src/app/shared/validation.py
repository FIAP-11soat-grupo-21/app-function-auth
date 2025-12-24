class ValidationError(Exception):
    def __init__(self, message: str):
        self.message = message
        super().__init__(message)


class RequestValidator:
    @staticmethod
    def validate_cpf(cpf: str):
        if not cpf or len(cpf) != 11 or not cpf.isdigit():
            raise ValidationError("CPF inválido. Deve conter 11 dígitos numéricos")

    @staticmethod
    def validate_register_data(cpf: str, name: str, email: str):
        if not cpf or len(cpf) != 11 or not cpf.isdigit():
            raise ValidationError("CPF inválido. Deve conter 11 dígitos numéricos")
        if not name or len(name.strip()) == 0:
            raise ValidationError("Nome é obrigatório")
        if not email or "@" not in email:
            raise ValidationError("Email inválido")

