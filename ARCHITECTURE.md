# Docker Stack Architecture

## Overview
This Docker stack provides a complete infrastructure setup with:
- **Traefik**: Reverse proxy and load balancer with automatic SSL
- **Authentik**: Identity provider and SSO solution
- **PostgreSQL**: Primary database
- **Redis**: In-memory data store and cache
- **pgAdmin**: Database administration interface

## Network Architecture
```
Internet → Traefik (Port 80/443) → Services
                ↓
            Authentik Auth
                ↓
        Protected Services (pgAdmin, etc.)
```

## Authentication Flow
1. User accesses service through Traefik
2. Traefik forwards auth request to Authentik
3. Authentik validates user credentials
4. On success, request is forwarded to target service
5. On failure, user is redirected to Authentik login

## Service Dependencies
- Authentik depends on PostgreSQL and Redis
- pgAdmin integrates with Authentik for authentication
- All services communicate through Docker networks
- Traefik handles SSL termination and routing

## Security Features
- All secrets managed through Docker secrets
- Environment variables for non-sensitive configuration
- Network isolation between services
- Forward authentication for all protected services

