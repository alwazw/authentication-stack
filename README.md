# Docker Stack Deployment

This is a comprehensive Docker stack deployment with:
- **Traefik**: Reverse proxy and load balancer
- **Authentik**: Identity provider and SSO solution  
- **PostgreSQL**: Primary database
- **Redis**: In-memory data store and cache
- **pgAdmin**: Database administration interface

## Quick Start

1. **Deploy the stack:**
   ```bash
   python3 app.py
   ```

2. **Access the management interface:**
   - Open your browser to the provided URL
   - Use the web interface to deploy and manage the stack

3. **Access services:**
   - Traefik Dashboard: `http://localhost/dashboard/`
   - Authentik Admin: `http://auth.localhost`
   - pgAdmin: `http://pgadmin.localhost`

## Default Credentials

- **Username:** `alwazw`
- **Password:** `WaficWazzan!2`

## Configuration

All configuration is managed through environment variables in the `.env` file:

- `DOMAIN`: Base domain for services (default: localhost)
- `POSTGRES_*`: PostgreSQL configuration
- `REDIS_PASSWORD`: Redis authentication
- `AUTHENTIK_SECRET_KEY`: Authentik encryption key
- `PGADMIN_*`: pgAdmin configuration

## Security Features

- All secrets are properly managed
- Environment variables for configuration
- Network isolation between services
- Forward authentication through Authentik
- Secure file permissions

## Architecture

```
Internet → Traefik (Port 80/443) → Services
                ↓
            Authentik Auth
                ↓
        Protected Services
```

## Management

The web interface provides:
- One-click deployment
- Service status monitoring
- Log viewing
- Configuration management
- Service access links

## Production Deployment

For production use:
1. Update the `DOMAIN` in `.env` to your actual domain
2. Configure SSL certificates in Traefik
3. Update passwords and secrets
4. Review security settings

