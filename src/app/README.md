# Auth Function — Análise e Guia

Resumo curto

Esta aplicação é uma função AWS Lambda que expõe um pequeno serviço de autenticação/usuários. Funciona como um gateway para operações relacionadas a usuários: registrar um usuário (usando CPF como identificador), buscar usuário por CPF e criar um token anônimo. A persistência de usuários é realizada em Amazon Cognito (via API administrativa) e os tokens são JWTs assinados com um segredo (lido do SSM Parameter Store ou de variável de ambiente).

Objetivo deste README

- Explicar como a aplicação funciona internamente (arquitetura e fluxo).
- Listar dependências e requisitos para execução local e em AWS.
- Indicar quais recursos AWS precisam existir e quais permissões são necessárias.
- Enumerar variáveis de ambiente e parâmetros SSM usados.
- Mostrar exemplos de eventos para teste.

Checklist (o que este documento cobre)

- [x] Visão geral e função da aplicação
- [x] Arquitetura e fluxo de execução
- [x] Requisitos locais / dependências
- [x] Recursos AWS necessários e permissões IAM
- [x] Variáveis de ambiente e parâmetros SSM
- [x] Endpoints (rotas esperadas) e exemplos de eventos
- [x] Observações de segurança e recomendações

1) Função da aplicação

A função principal da aplicação é fornecer endpoints para:
- Registrar usuário (cpf, name, email) — cria um usuário no Cognito e retorna um JWT.
- Buscar usuário por CPF — consulta o usuário no Cognito, gera e retorna um JWT com os dados.
- Criar um usuário anônimo — retorna um JWT anônimo (payload com id anônimo).

O CPF é usado como Username no Cognito. O token é gerado localmente pelo serviço com algoritmo HS256 (biblioteca PyJWT).

2) Arquitetura e componentes

- lambda_function.lambda_handler: ponto de entrada da Lambda.
- drivers.lambda_adapter.LambdaAdapter: constrói o AuthService e delega o evento ao controller.
- drivers.auth_controller.AuthController: extrai rota e corpo do evento, valida entrada e chama os métodos do serviço de aplicação para cada rota.
- application.auth_service.AuthService: orquestra os casos de uso (register, find by cpf, create anonymous).
- domain.use_cases.*: regras de negócio:
  - register_user: verifica existência (user_exists) e salva (save) via repository; gera token.
  - find_user_by_cpf: valida CPF, busca via repository e gera token.
  - create_anonymous_user: gera token anônimo.
- domain.entities.user.User e AuthResult: modelos de domínio e validações básicas (CPF 11 dígitos, email com @, nome obrigatório).
- driven.adapters.cognito_user_repository.CognitoUserRepository: implementação de UserRepositoryInterface usando boto3 (cognito-idp). Usa admin_get_user, admin_create_user e trata UserNotFoundException.
- driven.adapters.jwt_token_service.JWTTokenService: implementação de TokenServiceInterface usando PyJWT para gerar/validar tokens HS256.
- driven.config.settings.Settings: lê configurações do ambiente e busca o JWT secret no SSM Parameter Store em /tech-challenge/jwt-secret; permite fallback para variável de ambiente JWT_SECRET.

3) Fluxo de execução (exemplo de /registrar)

1. API Gateway (ou invocador) envia evento para Lambda com resource/path indicando a rota (por exemplo "/registrar").
2. lambda_handler instancia LambdaAdapter.
3. LambdaAdapter cria AuthService via AuthServiceFactory (que instancia CognitoUserRepository e JWTTokenService usando `driven.config.settings`).
4. AuthController extrai rota e corpo JSON.
5. Controller valida dados (RequestValidator) e chama o use case correspondente.
6. Use case usa o repository para salvar/consultar usuário e o token service para gerar JWT.
7. Controller retorna HttpResponse formatado (status, body) que a Lambda devolve.

4) Requisitos / dependências

- Python 3.8+ (compatível com boto3 e PyJWT; testar com a runtime da Lambda desejada).
- Dependências definidas em `requirements.txt`:
  - PyJWT==2.10.1
  - boto3==1.35.0
- Credenciais AWS (para execução local) com permissões para Cognito (cognito-idp) e SSM read.

5) Recursos AWS necessários

Mínimo necessário para executar em produção:

- AWS Lambda function (runtime compatível com Python 3.8/3.9/3.10 conforme compatibilidade local).
  - Variáveis de ambiente: USER_POOL_ID, CLIENT_ID (opcional), (JWT_SECRET apenas para fallback de dev).
  - Role de execução com políticas abaixo.
- Amazon Cognito User Pool
  - Configurar atributos de usuário para aceitar `name` e `email` (o código grava esses atributos).
  - O app/cliente (Client ID) pode ser usado se necessário; o repositório utiliza apenas Admin APIs com USER_POOL_ID.
- SSM Parameter Store
  - Chave para o JWT secret em: /tech-challenge/jwt-secret (com WithDecryption=True, encriptada com KMS). 
  - Alternativa: definir JWT_SECRET como variável de ambiente (não recomendado em produção).
- API Gateway (HTTP API ou REST API)
  - Três rotas esperadas (mapeadas para a mesma Lambda): /anonimo, /consultacpf, /registrar
  - As rotas podem ser definidas como recursos ou paths; o controller extrai a última parte do resource/path para decidir a ação.

6) Permissões IAM necessárias (role da Lambda)

A role usada pela Lambda precisa das ações:

- Cognito IdP (aplicadas ao User Pool):
  - cognito-idp:AdminGetUser
  - cognito-idp:AdminCreateUser
  - cognito-idp:ListUsers (opcional, se decidir listar)
- SSM Parameter Store:
  - ssm:GetParameter (para o caminho /tech-challenge/jwt-secret)
  - kms:Decrypt (se o parâmetro estiver encriptado com KMS e a Lambda precisar desencriptar)

Exemplo de policy JSON (simplificado):
- Permitir apenas os recursos necessários (UserPool ARN e SSM parameter ARN) em produção.

7) Variáveis de ambiente e parâmetros

- USER_POOL_ID (obrigatória) — ID do User Pool do Cognito.
- CLIENT_ID (opcional) — Client ID do app client do Cognito (o repositório aceita None).
- JWT_SECRET (opcional, dev only) — fallback local para funcionalidades de geração de token; em produção o segredo vem do SSM param store `/tech-challenge/jwt-secret`.

SSM Parameter usado (no código):
- /tech-challenge/jwt-secret — parâmetro (SecureString) contendo a chave secreta para assinar tokens JWT. Recomenda-se usar SecureString com KMS.

8) Rotas / Endpoints esperados e formato dos eventos

O controller usa event["resource"] ou event["path"] e considera a parte final do path (lowercase) como rota. Portanto, os caminhos esperados são:
- /anonimo — cria token anônimo. Método: GET ou POST.
- /consultacpf — busca usuário por CPF. Método: POST com body JSON {"cpf": "00000000000"}
- /registrar — registra usuário. Método: POST com body JSON {"cpf":"00000000000","name":"Nome","email":"a@b.com"}

Exemplo de evento de teste (registrar):
{
  "resource": "/registrar",
  "body": "{\"cpf\": \"12345678901\", \"name\": \"Fulano\", \"email\": \"fulano@exemplo.com\"}"
}

Exemplo (consultacpf):
{
  "resource": "/consultacpf",
  "body": "{\"cpf\": \"12345678901\"}"
}

Exemplo (anonimo):
{
  "resource": "/anonimo"
}

9) Observações de segurança e recomendações

- Nunca deixar JWT_SECRET em plain text em variáveis de ambiente em produção; use SSM SecureString com KMS e restrinja acesso via IAM.
- A role da Lambda deve ter o mínimo de privilégios: restringir acesso ao User Pool específico e ao parâmetro SSM específico.
- O uso de AdminCreateUser cria o usuário no Cognito sem senha (MessageAction="SUPPRESS"). Caso precise permitir login direto, é necessário fluxos adicionais (definir senha, confirmar usuário ou enviar convite).
- Verificar compliance de armazenamento do CPF (dados sensíveis). Em produção, avaliar criptografia em trânsito (HTTPS) e em descanso e limitar logs que exponham CPFs completos.

10) Como testar localmente

Pré-requisitos:
- Ter AWS credentials (perfil ou variáveis AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY) configuradas localmente com permissões de leitura ao SSM e operações Cognito.
- Exportar variáveis de ambiente (Windows PowerShell):

```powershell
$env:USER_POOL_ID = "us-east-1_example"
$env:CLIENT_ID = "exampleclientid"
$env:JWT_SECRET = "dev-secret-for-local-testing"
```

- Instalar dependências:

```powershell
python -m pip install -r requirements.txt
```

- Executar um teste rápido usando o handler:

```python
from lambda_function import lambda_handler
# exemplo de evento
event = {"resource": "/anonimo"}
print(lambda_handler(event, None))
```

11) Pontos de atenção e melhorias futuras

- Implementar logs estruturados e rastreabilidade (correlation id).
- Implementar testes unitários e de integração (mock boto3) para os adaptadores.
- Adicionar rate limiting e proteção contra abuso (API Gateway + WAF).
- Melhorar validação de CPF (algoritmo de dígitos verificadores) caso necessário.
- Implementar rotação de secrets e verificação de expiração de tokens se for necessário controlar sessão.

12) Mapeamento rápido entre arquivos e responsabilidades

- lambda_function.py — entrypoint
- drivers/lambda_adapter.py — adaptação do evento para controller
- drivers/auth_controller.py — validação e roteamento
- application/auth_service.py — orquestração dos use cases
- domain/use_cases/* — regras de negócio
- domain/entities/user.py — entidade e AuthResult
- domain/ports/* — interfaces (repository, token service)
- driven/adapters/cognito_user_repository.py — implementação Cognito
- driven/adapters/jwt_token_service.py — implementação JWT
- driven/config/settings.py — leitura de env e SSM

Fim do documento — se quiser, aplico este README.md no repositório ou ajusto o conteúdo com mais detalhes (ex.: políticas IAM completas, CloudFormation/Terraform, ou exemplos de deploy).
