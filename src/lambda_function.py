import json
import os
import logging
import base64
import hashlib
import hmac
import boto3
from botocore.exceptions import ClientError

# ...existing code...

LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
logger = logging.getLogger(__name__)
logger.setLevel(LOG_LEVEL)

COGNITO_CLIENT_ID = os.getenv('COGNITO_CLIENT_ID')
COGNITO_CLIENT_SECRET = os.getenv('COGNITO_CLIENT_SECRET')
COGNITO_USER_POOL_ID = os.getenv('COGNITO_USER_POOL_ID')
AWS_REGION = os.getenv('AWS_REGION')

def _calc_secret_hash(email: str, client_id: str, client_secret: str) -> str:
    """Calcula o SECRET_HASH necessário se o App Client tiver Client Secret.

    secret_hash = Base64( HMAC-SHA256( client_secret, email + client_id ) )
    """
    message = email + client_id
    dig = hmac.new(
        client_secret.encode('utf-8'),
        message.encode('utf-8'),
        hashlib.sha256
    ).digest()
    return base64.b64encode(dig).decode()


def _response(status_code: int, body: dict):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(body)
    }


def lambda_handler(event, context):
    """Lambda handler para POST /auth via API Gateway v2 (HTTP API).
    Entrada (event): espera event['body'] contendo JSON com 'email' e 'senha' (aceita
    também 'email' e 'password' como fallback).
    Saída: dicionário compatível com integração Lambda proxy (HTTP API v2).
    """
    logger.info('handle_auth invoked')

    body_raw = event.get('body')
    if body_raw is None:
        return _response(400, {'error': 'invalid_request', 'message': 'Request body is required.'})

    if event.get('isBase64Encoded'):
        try:
            body_raw = base64.b64decode(body_raw).decode('utf-8')
        except Exception:
            return _response(400, {'error': 'invalid_request', 'message': 'Invalid base64 body'})

    try:
        body = json.loads(body_raw)
    except Exception:
        return _response(400, {'error': 'invalid_request', 'message': 'Request body must be valid JSON'})

    username = body.get('username')
    password = body.get('password')

    if not username or not password:
        return _response(400, {'error': 'invalid_request', 'message': 'Both username and password are required.'})

    client_id = COGNITO_CLIENT_ID
    client_secret = COGNITO_CLIENT_SECRET
    region = AWS_REGION or None

    if not client_id:
        return _response(500, {'error': 'server_error', 'message': 'COGNITO_CLIENT_ID not configured.'})

    auth_params = {
        'USERNAME': username,
        'PASSWORD': password
    }

    if client_secret:
        try:
            auth_params['SECRET_HASH'] = _calc_secret_hash(username, client_id, client_secret)
        except Exception:
            logger.exception('Failed to calculate secret hash')
            return _response(500, {'error': 'server_error', 'message': 'Failed to calculate client secret hash.'})

    try:
        client = boto3.client('cognito-idp', region_name=region) if region else boto3.client('cognito-idp')
        resp = client.initiate_auth(
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters=auth_params,
            ClientId=client_id
        )

        auth_result = resp.get('AuthenticationResult', {})
        if not auth_result:
            # Could be a challenge response
            challenge = resp.get('ChallengeName')
            logger.info('Cognito returned a challenge: %s', challenge)
            return _response(403, {'error': 'challenge_required', 'message': 'Additional challenge required', 'challenge': challenge})

        # Prefer IdToken (JWT). If not present, fallback to AccessToken.
        token = auth_result.get('IdToken') or auth_result.get('AccessToken')
        result = {
            'token': token,
            'expires_in': auth_result.get('ExpiresIn'),
            'token_type': auth_result.get('TokenType')
        }

        logger.info('Authentication successful for user (username=%s)', username)

        return _response(200, result)

    except ClientError as e:
        code = e.response.get('Error', {}).get('Code')
        logger.info('Cognito ClientError: %s', code)
        if code == 'NotAuthorizedException':
            return _response(401, {'error': 'invalid_credentials', 'message': 'Invalid email or password.'})
        if code == 'UserNotFoundException':
            return _response(404, {'error': 'user_not_found', 'message': 'User does not exist.'})
        if code == 'UserNotConfirmedException':
            return _response(403, {'error': 'user_not_confirmed', 'message': 'User not confirmed.'})
        if code == 'PasswordResetRequiredException':
            return _response(403, {'error': 'password_reset_required', 'message': 'Password reset required.'})

        # Generic client error
        logger.exception('Unhandled Cognito ClientError')
        return _response(502, {'error': 'upstream_error', 'message': 'Cognito error: %s' % code})

    except Exception:
        logger.exception('Unexpected error in handle_auth')
        return _response(500, {'error': 'server_error', 'message': 'Unexpected server error.'})
