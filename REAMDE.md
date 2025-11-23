# Lambda Autorização - Tech Challenge

Repositório para criação de Lambda responsável por realizar a autenticação do sistema de Fast Food do Tech Challenge.

## 📋 Pré-requisitos

### AWS Academy Account
- Acesso ao AWS Academy com a role LabRole

### Buckets S3 (Criar manualmente antes do primeiro deploy)
1. **Bucket para Terraform State**: `tech-challenge-fase04-terraform-state`
2. **Bucket para Assets Lambda**: `tech-challenge-fase04-assets`

```bash
# Criar os buckets via AWS CLI
aws s3 mb s3://tech-challenge-fase04-terraform-state
aws s3 mb s3://tech-challenge-fase04-assets
```

## 🔧 Configuração do GitHub

### Secrets necessários no GitHub Actions
Vá em: `Settings > Secrets and variables > Actions > Repository secrets`

Adicione os seguintes secrets:
- `AWS_ACCESS_KEY_ID`: Sua access key do AWS Academy
- `AWS_SECRET_ACCESS_KEY`: Sua secret key do AWS Academy  
- `AWS_SESSION_TOKEN`: Seu session token do AWS Academy

## 🏗️ Arquitetura

### Componentes criados via Terraform:
- **AWS Lambda**: Lambda Function de autorização
- **API Gateway**: REST API com 3 endpoints:
  - `/anonimo` - Criação de usuário anônimo
  - `/consultacpf` - Consulta usuário por CPF
  - `/registrar` - Registro de novo usuário
- **Amazon Cognito**: User Pool para autenticação
- **Parameter Store**: Armazenamento seguro do JWT Secret

## 🚀 Pipeline CI/CD

### Trigger da Pipeline
A esteira roda automaticamente quando:
- **Pull Request** para `main` (apenas validação)
- **Push** para `main` (deploy completo)
- **Manual** via `workflow_dispatch`

## 🔄 Fluxo de Trabalho (Workflows)

### 1. Pull Requests (PRs)
- Todo código novo deve ser submetido via PR para o branch `main`.
- O workflow de validação é disparado automaticamente:
  - **Terraform Validate:** Verifica sintaxe e formatação dos arquivos Terraform.
  - **CI:** Garante que dependências e estrutura do projeto estão corretas.
- O PR só deve ser aprovado após validação e revisão de código.

### 2. Merge no Branch Main
- Após aprovação, o PR é mergeado no `main`.
- O workflow de deploy é disparado automaticamente:
  - **Terraform Deploy:** Aplica as mudanças na infraestrutura AWS.
  - **Build Lambda:** Instala dependências, empacota e faz upload do código para o S3.
  - **Provisionamento:** Atualiza recursos AWS (Lambda, API Gateway, Cognito, etc).
- O deploy é totalmente automatizado, sem necessidade de ação manual.

## 🛠️ Testando a API

### Endpoints disponíveis:
Após o deploy, use as URLs dos outputs do Terraform:

```bash
# Usuário anônimo
curl -X POST https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/dev/anonimo

# Registrar usuário
curl -X POST https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/dev/registrar \
  -H "Content-Type: application/json" \
  -d '{"cpf":"12345678901","name":"João","email":"joao@email.com"}'

# Consultar por CPF
curl -X POST "https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/dev/consultacpf" ^
  -H "Content-Type: application/json" ^
  -d "{\"cpf\":\"12345678901\"}"
```

