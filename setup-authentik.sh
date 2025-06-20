#!/bin/bash

# Authentik Setup Script
# This script configures Authentik after the initial deployment

set -e

echo "Setting up Authentik configuration..."

# Wait for Authentik to be ready
echo "Waiting for Authentik to start..."
sleep 30

# Create superuser
echo "Creating Authentik superuser..."
docker exec authentik-server ak create_admin_group
docker exec authentik-server ak create_admin_user \
    --username alwazw \
    --email admin@${DOMAIN:-localhost} \
    --password "WaficWazzan!2"

echo "Authentik superuser created successfully!"

# Configure OAuth2/OIDC Provider for pgAdmin
echo "Setting up OAuth2 provider for pgAdmin..."

# Note: The following would typically be done through the Authentik web interface
# For automation, we would use the Authentik API or management commands

cat << 'EOF' > /tmp/authentik_setup.py
#!/usr/bin/env python3
"""
Authentik configuration script
This script sets up providers and applications for the services
"""

import requests
import json
import time
import os

AUTHENTIK_URL = f"https://auth.{os.getenv('DOMAIN', 'localhost')}"
USERNAME = "alwazw"
PASSWORD = "WaficWazzan!2"

def get_auth_token():
    """Get authentication token from Authentik"""
    login_url = f"{AUTHENTIK_URL}/api/v3/flows/executor/default-authentication-flow/"
    
    session = requests.Session()
    
    # Get the login page to extract CSRF token
    response = session.get(login_url)
    
    # Login
    login_data = {
        "uid_field": USERNAME,
        "password": PASSWORD,
    }
    
    response = session.post(f"{AUTHENTIK_URL}/api/v3/flows/executor/default-authentication-flow/", 
                           data=login_data)
    
    if response.status_code == 200:
        # Get API token
        token_response = session.post(f"{AUTHENTIK_URL}/api/v3/core/tokens/", 
                                    json={"identifier": "setup-token", "description": "Setup token"})
        if token_response.status_code == 201:
            return token_response.json()["key"]
    
    return None

def create_oauth_provider():
    """Create OAuth2/OIDC provider for pgAdmin"""
    token = get_auth_token()
    if not token:
        print("Failed to get authentication token")
        return
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    # Create OAuth2 provider
    provider_data = {
        "name": "pgAdmin OAuth2",
        "authorization_flow": "default-provider-authorization-explicit-consent",
        "client_type": "confidential",
        "client_id": "pgadmin",
        "redirect_uris": f"https://pgadmin.{os.getenv('DOMAIN', 'localhost')}/oauth2/authorize",
        "sub_mode": "hashed_user_id",
        "include_claims_in_id_token": True,
        "issuer_mode": "per_provider"
    }
    
    response = requests.post(f"{AUTHENTIK_URL}/api/v3/providers/oauth2/", 
                           headers=headers, json=provider_data)
    
    if response.status_code == 201:
        provider_id = response.json()["pk"]
        print(f"OAuth2 provider created with ID: {provider_id}")
        
        # Create application
        app_data = {
            "name": "pgAdmin",
            "slug": "pgadmin",
            "provider": provider_id,
            "meta_launch_url": f"https://pgadmin.{os.getenv('DOMAIN', 'localhost')}",
            "meta_icon": "https://www.pgadmin.org/static/COMPILED/assets/img/favicon.ico"
        }
        
        app_response = requests.post(f"{AUTHENTIK_URL}/api/v3/core/applications/", 
                                   headers=headers, json=app_data)
        
        if app_response.status_code == 201:
            print("pgAdmin application created successfully")
        else:
            print(f"Failed to create application: {app_response.text}")
    else:
        print(f"Failed to create provider: {response.text}")

if __name__ == "__main__":
    time.sleep(60)  # Wait for Authentik to be fully ready
    create_oauth_provider()
EOF

# Make the script executable and run it
chmod +x /tmp/authentik_setup.py
python3 /tmp/authentik_setup.py

echo "Authentik configuration completed!"
echo "You can now access:"
echo "- Authentik Admin: https://auth.${DOMAIN:-localhost}/if/admin/"
echo "- pgAdmin: https://pgadmin.${DOMAIN:-localhost}"
echo "- Traefik Dashboard: https://traefik.${DOMAIN:-localhost}"

