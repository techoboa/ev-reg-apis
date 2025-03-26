#############################################################################################
# Author                Date            Version         Change
# Anurag Shrivastava    03/24/2025      1.0             API Authentication helper module.
#
#############################################################################################

# Improvement areas: 
# 1. Fetch API users and passwords from a secret manager like HKV, AKV etc. Currently hardcoded.
# 2. Use advanced mechanisms like Token based security
# 3. Secure the APIs using TLS and Certs

from flask import Flask, request, jsonify, Response
from functools import wraps

### TO DO: Authentication. In real world, get credentials from a secret vault
def check_auth(username, password):
    """Checks if username/password combination is valid."""
    return username == 'admin' and password == 'secret'

def authenticate():
    """Sends a 401 response that enables basic auth"""
    return Response(
    'Could not verify your access', 401,
    {'WWW-Authenticate': 'Basic realm="Login Required"'})

def requires_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or not check_auth(auth.username, auth.password):
            return authenticate()
        return f(*args, **kwargs)
    return decorated