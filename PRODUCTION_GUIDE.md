# Production Deployment Guide

Complete guide for deploying the Docker Authentication Stack in production environments.

## 🎯 Production Overview

This stack provides enterprise-grade authentication and database management with:
- **High Availability**: Health checks and automatic restarts
- **Security**: Centralized authentication, secrets management, SSL/TLS
- **Scalability**: Microservices architecture with isolated networks
- **Monitoring**: Built-in dashboards and logging

## 🏗️ Architecture

```
Internet → Traefik (80/443) → Authentik Authentication → Protected Services
                ↓                        ↓
            SSL Termination         User Management
                ↓                        ↓
            Load Balancing          OAuth/OIDC/SAML
                ↓                        ↓
        Service Discovery           Policy Engine
```

### Service Components
- **Traefik v3.0**: Edge router with automatic SSL and service discovery
- **Authentik 2024.2.2**: Identity provider with OAuth2/OIDC/SAML support
- **PostgreSQL 15**: Primary database with Alpine Linux for security
- **Redis 7**: Session storage and caching layer
- **pgAdmin 4**: Database administration (direct port access)

## 🚀 Production Deployment

### 1. Server Requirements

**Minimum Specifications:**
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 20GB SSD
- **OS**: Ubuntu 20.04+ or CentOS 8+

**Recommended Specifications:**
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Storage**: 50GB+ SSD
- **Network**: Static IP with domain name

### 2. Pre-Deployment Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

### 3. Domain and DNS Configuration

```bash
# Configure DNS records (replace with your domain)
# A record: yourdomain.com → your-server-ip
# A record: *.yourdomain.com → your-server-ip (for subdomains)

# Or for IP-based deployment, use your server IP directly
```

### 4. Production Deployment

```bash
# Clone repository
git clone https://github.com/alwazw/authentication-stack.git
cd authentication-stack

# Create production environment
cp .env.example .env

# Edit production configuration
nano .env
```

**Production .env Configuration:**
```bash
# Domain Configuration
DOMAIN=yourdomain.com                    # Your production domain
ACME_EMAIL=admin@yourdomain.com         # Email for SSL certificates

# Database Configuration
POSTGRES_DB=production_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-very-secure-db-password-here

# Cache Configuration
REDIS_PASSWORD=your-very-secure-redis-password-here

# Authentication Configuration
AUTHENTIK_SECRET_KEY=your-50-character-secret-key-here
AUTHENTIK_BOOTSTRAP_PASSWORD=your-very-secure-admin-password
AUTHENTIK_BOOTSTRAP_EMAIL=admin@yourdomain.com

# Administration Configuration
PGADMIN_EMAIL=admin@yourdomain.com
PGADMIN_PASSWORD=your-very-secure-pgadmin-password

# Security Settings
COMPOSE_PROJECT_NAME=production-auth-stack
```

### 5. Security Hardening

```bash
# Run security setup
chmod +x security-setup.sh
./security-setup.sh

# Set up firewall
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw allow 5050/tcp    # pgAdmin
sudo ufw enable

# Secure file permissions
chmod 600 .env
chmod -R 700 secrets/
chmod -R 755 config/
```

### 6. Deploy Production Stack

```bash
# Deploy the stack
docker compose up -d

# Verify deployment
docker compose ps
docker compose logs -f
```

## 🌐 Production Service Access

### Primary Services
- **Authentication Portal**: https://yourdomain.com/
- **Traefik Dashboard**: https://yourdomain.com/dashboard/
- **Database Admin**: https://yourdomain.com:5050/

### SSL Certificates
Traefik automatically handles SSL certificates via Let's Encrypt:
- Automatic certificate generation
- Auto-renewal before expiration
- HTTP to HTTPS redirection
- Certificates stored in `data/traefik/acme.json`

## 🔒 Production Security

### Authentication Flow
1. **User Access**: All requests go through Traefik
2. **Authentication Check**: Traefik forwards auth to Authentik
3. **Authorization**: Authentik validates user and permissions
4. **Service Access**: Authenticated users access protected services

### Security Features
- **Forward Authentication**: All services protected by Authentik
- **Network Isolation**: Services communicate on isolated Docker networks
- **Secrets Management**: Sensitive data stored in Docker secrets
- **SSL/TLS**: End-to-end encryption with automatic certificate management
- **Health Monitoring**: Automatic service restart on failure

### User Management
Access Authentik admin at https://yourdomain.com/ to:
- Create and manage users and groups
- Configure OAuth2/OIDC providers
- Set up SAML integration
- Define access policies and rules
- Monitor authentication events

## 📊 Monitoring and Maintenance

### Health Checks
All services include built-in health monitoring:

```bash
# Check service health
docker compose ps

# View health check logs
docker compose logs --tail 50 postgresql
docker compose logs --tail 50 redis
```

### Log Management
```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f authentik-server
docker compose logs -f traefik

# Export logs for analysis
docker compose logs --since 24h > stack-logs.txt
```

### Backup Strategy

**Database Backups:**
```bash
# Create backup script
cat > backup-db.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker exec postgresql pg_dump -U postgres production_db > backup_${DATE}.sql
gzip backup_${DATE}.sql
EOF

chmod +x backup-db.sh

# Set up daily backups via cron
echo "0 2 * * * /path/to/backup-db.sh" | crontab -
```

**Configuration Backups:**
```bash
# Backup entire stack configuration
tar -czf auth-stack-backup-$(date +%Y%m%d).tar.gz \
  docker-compose.yml .env config/ secrets/
```

### Updates and Maintenance

**Update Docker Images:**
```bash
# Pull latest images
docker compose pull

# Restart with new images
docker compose down && docker compose up -d

# Clean up old images
docker image prune -f
```

**Monitor Resource Usage:**
```bash
# Check container resource usage
docker stats

# Check disk usage
df -h
docker system df
```

## 🔧 Production Troubleshooting

### Common Issues

**SSL Certificate Issues:**
```bash
# Check certificate status
docker compose logs traefik | grep -i acme

# Force certificate renewal
docker exec traefik rm /data/acme.json
docker compose restart traefik
```

**Database Connection Issues:**
```bash
# Test database connectivity
docker exec postgresql pg_isready -U postgres

# Check database logs
docker compose logs postgresql
```

**Authentication Problems:**
```bash
# Check Authentik status
docker compose logs authentik-server

# Verify Authentik database connection
docker exec authentik-server ak check_db
```

**Service Discovery Issues:**
```bash
# Check Traefik service discovery
docker exec traefik wget -qO- http://localhost:8080/api/http/services

# Restart Traefik to refresh discovery
docker compose restart traefik
```

### Performance Optimization

**Database Tuning:**
```bash
# Add to postgresql service in docker-compose.yml
command: >
  postgres
  -c shared_buffers=256MB
  -c effective_cache_size=1GB
  -c maintenance_work_mem=64MB
  -c checkpoint_completion_target=0.9
```

**Redis Optimization:**
```bash
# Add to redis service in docker-compose.yml
command: >
  redis-server
  --requirepass ${REDIS_PASSWORD}
  --maxmemory 512mb
  --maxmemory-policy allkeys-lru
```

## 🚀 Scaling and High Availability

### Horizontal Scaling
```bash
# Scale Authentik workers
docker compose up -d --scale authentik-worker=3

# Add load balancer for multiple instances
# Configure external load balancer to distribute traffic
```

### Database High Availability
```bash
# Set up PostgreSQL streaming replication
# Configure read replicas for improved performance
# Implement automated failover mechanisms
```

### Monitoring Integration
```bash
# Add Prometheus monitoring
# Configure Grafana dashboards
# Set up alerting for critical events
```

## 📋 Production Checklist

### Pre-Deployment
- [ ] Server meets minimum requirements
- [ ] Domain and DNS configured
- [ ] SSL certificates working
- [ ] Firewall rules configured
- [ ] Backup strategy implemented

### Post-Deployment
- [ ] All services healthy and accessible
- [ ] Authentication flow working
- [ ] SSL certificates auto-renewing
- [ ] Monitoring and alerting configured
- [ ] Backup and recovery tested

### Security Review
- [ ] Default passwords changed
- [ ] User access policies configured
- [ ] Network security validated
- [ ] Log monitoring enabled
- [ ] Security updates scheduled

## 📞 Production Support

### Monitoring Endpoints
- **Traefik API**: http://localhost:8080/api/rawdata
- **Authentik Health**: http://localhost:9000/-/health/live/
- **PostgreSQL**: Use pgAdmin or direct connection

### Log Locations
- **Application Logs**: `docker compose logs [service]`
- **Traefik Logs**: Container logs and access logs
- **System Logs**: `/var/log/syslog` and `/var/log/docker`

### Emergency Procedures
```bash
# Emergency stop
docker compose down

# Emergency restart
docker compose down && docker compose up -d

# Rollback to previous version
git checkout previous-commit
docker compose down && docker compose up -d
```

---

## 🎯 Production Success Metrics

Your production deployment should achieve:
- **99.9% Uptime**: With proper monitoring and health checks
- **Sub-second Response**: For authentication and service access
- **Zero Downtime Updates**: Using rolling deployment strategies
- **Automated Recovery**: From common failure scenarios

**Production URL Structure:**
- Main Authentication: https://yourdomain.com/
- Admin Dashboard: https://yourdomain.com/dashboard/
- Database Management: https://yourdomain.com:5050/

Your Docker Authentication Stack is now production-ready! 🚀

