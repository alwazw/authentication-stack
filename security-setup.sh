#!/bin/bash

# Security Setup Script
# This script sets up proper permissions and security configurations

set -e

echo "Setting up security configurations..."

# Create necessary directories
mkdir -p data/{postgresql,redis,authentik/{media,custom-templates},pgadmin}
mkdir -p config/{traefik,postgresql,pgadmin}
mkdir -p secrets

# Set proper ownership and permissions
echo "Setting file permissions..."

# Environment files
chmod 600 .env
chmod 644 .env.example

# Secrets
chmod 700 secrets/
chmod 600 secrets/*

# Data directories
chmod 755 data/
chmod 700 data/postgresql/
chmod 755 data/redis/
chmod 755 data/authentik/
chmod 755 data/pgadmin/

# Traefik ACME file
chmod 600 data/traefik/acme.json

# Configuration files
chmod 644 config/traefik/dynamic.yml
chmod 644 config/postgresql/init.sql
chmod 644 config/pgadmin/servers.json

# Scripts
chmod +x setup-authentik.sh
chmod +x security-setup.sh

echo "Security setup completed!"

# Generate additional secrets if needed
if [ ! -f "secrets/redis_password.txt" ]; then
    echo "Generating Redis password..."
    openssl rand -base64 32 > secrets/redis_password.txt
    chmod 600 secrets/redis_password.txt
fi

if [ ! -f "secrets/authentik_secret.txt" ]; then
    echo "Generating Authentik secret key..."
    openssl rand -base64 64 > secrets/authentik_secret.txt
    chmod 600 secrets/authentik_secret.txt
fi

echo "All secrets generated and secured!"

# Validate configuration
echo "Validating Docker Compose configuration..."
docker-compose config > /dev/null && echo "✓ Docker Compose configuration is valid" || echo "✗ Docker Compose configuration has errors"

echo "Security setup completed successfully!"

