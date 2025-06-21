# Docker Authentication Stack

A comprehensive Docker stack deployment with enterprise-grade authentication and database management:

- **Traefik**: Reverse proxy and load balancer with automatic SSL
- **Authentik**: Identity provider and SSO solution  
- **PostgreSQL**: Primary database with health monitoring
- **Redis**: In-memory data store and cache
- **pgAdmin**: Database administration interface

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Git for cloning the repository

### Local Deployment

```bash
# Clone the repository
git clone https://github.com/alwazw/authentication-stack.git
cd authentication-stack

# Copy and configure environment
cp .env.example .env
# Edit .env with your domain and credentials

# Set up security and permissions
chmod +x security-setup.sh
./security-setup.sh

# Deploy the stack
docker compose up -d

# Check service status
docker compose ps
```

## 🌐 Service Access

After deployment, access your services at:

- **Authentik (Main Auth)**: http://your-domain/
- **Traefik Dashboard**: http://your-domain/dashboard/
- **pgAdmin**: http://your-domain:5050/

### Default Credentials
- **Username**: `alwazw`
- **Password**: `WaficWazzan!2`
- **pgAdmin Email**: Update in `.env` file

## 📋 Configuration

### Environment Variables (.env)
Key configuration options:

```bash
# Domain Configuration
DOMAIN=your-domain-or-ip

# Email Configuration (replace with your email)
ACME_EMAIL=your-email@domain.com
AUTHENTIK_BOOTSTRAP_EMAIL=your-email@domain.com
PGADMIN_EMAIL=your-email@domain.com

# Database Configuration
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-secure-password

# Authentication
AUTHENTIK_SECRET_KEY=your-generated-secret-key
AUTHENTIK_BOOTSTRAP_PASSWORD=your-secure-password
PGADMIN_PASSWORD=your-secure-password
```

## 🏗️ Architecture

```
Internet → Traefik (Port 80/443) → Services
                ↓
            Authentik Auth
                ↓
        Protected Services
```

### Service Details:
- **Traefik**: Routes traffic and handles SSL termination
- **Authentik**: Provides authentication for all services
- **PostgreSQL**: Database backend with automatic initialization
- **Redis**: Cache and session storage
- **pgAdmin**: Direct access on port 5050 (no proxy routing)

## 🔒 Security Features

- **Secrets Management**: Docker secrets for sensitive data
- **Network Isolation**: Separate networks for different service tiers
- **Authentication**: Centralized auth through Authentik
- **SSL/TLS**: Automatic certificate management via Traefik
- **Secure Defaults**: Proper file permissions and configurations

## 🔧 Management

### Web Management Interface
Run the included management interface:

```bash
# Install dependencies
pip install -r requirements.txt

# Start management interface
python app.py
```

Access at http://localhost:5000 for web-based stack management.

### Command Line Management

```bash
# View service status
docker compose ps

# View logs
docker compose logs -f [service-name]

# Restart services
docker compose restart [service-name]

# Stop the stack
docker compose down

# Update and restart
docker compose down && docker compose up -d
```

## 📁 Project Structure

```
authentication-stack/
├── docker-compose.yml          # Main orchestration
├── .env.example               # Environment template
├── config/                    # Service configurations
│   ├── traefik/dynamic.yml   # Traefik routing rules
│   ├── postgresql/init.sql   # Database initialization
│   └── pgadmin/servers.json  # pgAdmin server config
├── secrets/                   # Secure credential storage
├── data/                      # Persistent data volumes
├── security-setup.sh         # Security configuration
├── setup-authentik.sh        # Authentik setup helper
└── docs/                     # Additional documentation
```

## 🚀 Production Deployment

### Domain Configuration
1. Update `DOMAIN` in `.env` to your actual domain
2. Configure DNS to point to your server
3. Update email addresses in `.env`
4. Generate secure passwords and secrets

### SSL Configuration
Traefik automatically handles SSL certificates:
- Let's Encrypt integration
- Automatic renewal
- HTTP to HTTPS redirection

### Security Hardening
1. Change all default passwords
2. Review and update `.env` configuration
3. Set up regular backups
4. Configure monitoring and alerting

## 🔍 Troubleshooting

### Common Issues

**Services not accessible:**
- Check if Docker is running: `docker ps`
- Verify containers are healthy: `docker compose ps`
- Check logs: `docker compose logs [service]`

**Authentication issues:**
- Verify Authentik is running and accessible
- Check forward auth configuration
- Clear browser cookies and cache

**pgAdmin connection issues:**
- Ensure PostgreSQL is running and healthy
- Verify database credentials in `.env`
- Check pgAdmin logs: `docker compose logs pgadmin`

**Domain resolution:**
- For local testing, add entries to `/etc/hosts`
- For production, verify DNS configuration

### Log Access
```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f authentik-server
docker compose logs -f traefik
docker compose logs -f pgadmin
```

## 📚 Additional Documentation

- [Quick Start Guide](QUICK_START.md) - Detailed setup instructions
- [Production Guide](PRODUCTION_GUIDE.md) - Production deployment guide
- [Architecture Overview](ARCHITECTURE.md) - System architecture details

## 🎯 Next Steps

1. **Initial Setup**: Deploy and verify all services
2. **Configuration**: Update credentials and domain settings
3. **Authentication**: Configure users and groups in Authentik
4. **Database**: Set up your databases and connections in pgAdmin
5. **Monitoring**: Implement backup and monitoring strategies

## 📞 Support

For issues and questions:
- Check the troubleshooting section above
- Review service-specific documentation
- Check Docker and service logs
- Verify configuration in `.env` file

---

**Repository**: https://github.com/alwazw/authentication-stack  
**License**: MIT  
**Maintainer**: alwazw

