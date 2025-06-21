# Quick Start Guide

Get your Docker authentication stack running in minutes!

## 📋 Prerequisites

- Docker and Docker Compose v2 installed
- Git for repository cloning
- 4GB+ RAM and 10GB+ disk space

## 🚀 Installation Steps

### 1. Clone and Setup
```bash
# Clone the repository
git clone https://github.com/alwazw/authentication-stack.git
cd authentication-stack

# Copy environment template
cp .env.example .env
```

### 2. Configure Environment
Edit the `.env` file with your settings:

```bash
# Essential configurations to update:
DOMAIN=192.168.1.100                    # Your server IP or domain
ACME_EMAIL=your-email@domain.com        # Your email for SSL certificates
AUTHENTIK_BOOTSTRAP_EMAIL=your-email@domain.com
PGADMIN_EMAIL=your-email@domain.com

# Update passwords (recommended):
POSTGRES_PASSWORD=your-secure-db-password
REDIS_PASSWORD=your-secure-redis-password
AUTHENTIK_BOOTSTRAP_PASSWORD=your-secure-auth-password
PGADMIN_PASSWORD=your-secure-pgadmin-password
```

### 3. Security Setup
```bash
# Make scripts executable and run security setup
chmod +x security-setup.sh
./security-setup.sh
```

### 4. Deploy the Stack
```bash
# Start all services
docker compose up -d

# Check service status
docker compose ps

# View logs (optional)
docker compose logs -f
```

## 🌐 Access Your Services

Once deployed, access your services at:

### Primary Services
- **🔐 Authentik (Authentication)**: http://your-domain/
- **📊 Traefik Dashboard**: http://your-domain/dashboard/
- **🗄️ pgAdmin (Database)**: http://your-domain:5050/

### Default Login Credentials
- **Username**: `alwazw`
- **Password**: `WaficWazzan!2` (or your custom password from `.env`)

## ✅ Verification Steps

### 1. Check Service Health
```bash
# All services should show "Up" and "healthy"
docker compose ps
```

Expected output:
```
NAME               STATUS
authentik-server   Up (healthy)
authentik-worker   Up (healthy)
pgadmin           Up
postgresql        Up (healthy)
redis             Up (healthy)
traefik           Up
```

### 2. Test Service Access
```bash
# Test Authentik (should return 302 redirect)
curl -I http://your-domain/

# Test Traefik dashboard (should return 200)
curl -I http://your-domain/dashboard/

# Test pgAdmin (should return 200)
curl -I http://your-domain:5050/
```

### 3. Browser Testing
1. **Authentik**: Visit http://your-domain/ - should show login page
2. **Traefik**: Visit http://your-domain/dashboard/ - should show dashboard
3. **pgAdmin**: Visit http://your-domain:5050/ - should show pgAdmin login

## 🔧 Common Setup Issues

### Docker Compose Version Error
If you see "docker-compose: command not found":
```bash
# Install Docker Compose plugin
sudo apt install docker-compose-plugin

# Or use the new syntax
docker compose up -d
```

### Permission Errors
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
chmod +x *.sh
./security-setup.sh
```

### Port Conflicts
If ports 80, 443, or 5050 are in use:
```bash
# Check what's using the ports
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :5050

# Stop conflicting services or change ports in docker-compose.yml
```

### Service Not Starting
```bash
# Check specific service logs
docker compose logs authentik-server
docker compose logs traefik
docker compose logs pgadmin

# Restart problematic service
docker compose restart [service-name]
```

## 🎯 Next Steps

### 1. Initial Configuration
- [ ] Log into Authentik and create additional users
- [ ] Configure authentication policies
- [ ] Set up database connections in pgAdmin

### 2. Security Hardening
- [ ] Change all default passwords
- [ ] Review and update `.env` configuration
- [ ] Set up SSL certificates for production

### 3. Customization
- [ ] Add your domain to Traefik configuration
- [ ] Configure additional authentication providers
- [ ] Set up database backups

## 📱 Management Interface (Optional)

For web-based management:

```bash
# Install Python dependencies
pip install -r requirements.txt

# Start management interface
python app.py
```

Access at http://localhost:5000 for GUI-based stack management.

## 🆘 Troubleshooting

### Reset Everything
```bash
# Stop and remove all containers and volumes
docker compose down -v

# Clean up Docker system
docker system prune -f

# Start fresh
docker compose up -d
```

### View All Logs
```bash
# Follow all service logs
docker compose logs -f

# View last 50 lines for specific service
docker compose logs --tail 50 authentik-server
```

### Check Network Connectivity
```bash
# Test internal service communication
docker exec authentik-server ping postgresql
docker exec traefik ping authentik-server
```

## 📚 Additional Resources

- [Production Deployment Guide](PRODUCTION_GUIDE.md)
- [Architecture Overview](ARCHITECTURE.md)
- [Full Documentation](README.md)

---

**Need Help?** Check the troubleshooting section or review the logs for specific error messages.

