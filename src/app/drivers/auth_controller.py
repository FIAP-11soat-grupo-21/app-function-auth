import json
import logging
from typing import Dict, Any

from shared.http_response import HttpResponse
from shared.validation import RequestValidator, ValidationError

logger = logging.getLogger(__name__)

class AuthController:
    def __init__(self, auth_service):
        self.auth_service = auth_service
    
    def handle_request(self, event: Dict[str, Any]) -> Dict[str, Any]:
        try:
            route = self._extract_route(event)
            body = self._parse_body(event)
            logger.info(f"Rota: {route}, Body: {body}")
            
            if route == "anonimo":
                return self._handle_anonymous_user()
            elif route == "consultacpf":
                return self._handle_find_user(body)
            elif route == "registrar":
                return self._handle_register(body)
            else:
                return HttpResponse.error(404, "Rota não encontrada")
                
        except Exception as e:
            logger.error(f"Erro no controller: {e}")
            return HttpResponse.error(500, f"Erro interno: {str(e)}")
    
    def _extract_route(self, event: Dict[str, Any]) -> str:
        route = (event.get("resource") or event.get("path", "")).lower()
        return route.split("/")[-1]
    
    def _parse_body(self, event: Dict[str, Any]) -> Dict[str, Any]:
        body_str = event.get("body", "{}")
        return json.loads(body_str) if body_str else {}
    
    def _handle_register(self, body: Dict[str, Any]) -> Dict[str, Any]:
        try:
            cpf = body.get("cpf", "").strip()
            name = body.get("name", "").strip()
            email = body.get("email", "").strip()
            
            RequestValidator.validate_register_data(cpf, name, email)
            result = self.auth_service.register_user(cpf, name, email)
            
            if result.success:
                return HttpResponse.success(201, {
                    "cpf": result.user.cpf,
                    "name": result.user.name,
                    "email": result.user.email,
                    "token": result.token
                })
            else:
                return HttpResponse.error(400, result.message)
                
        except ValidationError as e:
            return HttpResponse.error(400, e.message)
        except Exception as e:
            logger.error(f"Erro no registro: {e}")
            return HttpResponse.error(500, f"Erro interno: {str(e)}")
    
    def _handle_find_user(self, body: Dict[str, Any]) -> Dict[str, Any]:
        try:
            cpf = body.get("cpf", "").strip()
            
            RequestValidator.validate_cpf(cpf)
            result = self.auth_service.find_user_by_cpf(cpf)
            
            if result.success:
                return HttpResponse.success(200, {
                    "cpf": result.user.cpf,
                    "name": result.user.name,
                    "email": result.user.email,
                    "token": result.token
                })
            else:
                status_code = 404 if "não encontrado" in result.message.lower() else 400
                return HttpResponse.error(status_code, result.message)
                
        except ValidationError as e:
            return HttpResponse.error(400, e.message)
        except Exception as e:
            logger.error(f"Erro na consulta: {e}")
            return HttpResponse.error(500, f"Erro interno: {str(e)}")
    
    def _handle_anonymous_user(self) -> Dict[str, Any]:
        try:
            result = self.auth_service.create_anonymous_user()
            
            if result.success:
                return HttpResponse.success(200, {
                    "token": result.token,
                    "type": "anonymous"
                })
            else:
                return HttpResponse.error(500, result.message)
                
        except Exception as e:
            logger.error(f"Erro no usuário anônimo: {e}")
            return HttpResponse.error(500, f"Erro interno: {str(e)}")
