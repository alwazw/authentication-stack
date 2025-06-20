# Quick Start Guide for Local Testing

## Clone and Setup

```bash
# Clone the repository
git clone https://github.com/alwazw/authentication-stack.git
cd authentication-stack

# Copy environment template and customize
cp .env.example .env

# Edit .env file with your domain (or keep localhost for local testing)
# Update passwords and secrets as needed

# Run security setup
chmod +x security-setup.sh
./security-setup.sh

# Start the stack
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

## Default Access

Once running, access services at:
- **Traefik Dashboard**: http://localhost/dashboard/
- **Authentik Admin**: http://auth.localhost
- **pgAdmin**: http://pgadmin.localhost

**Default Credentials:**
- Username: `alwazw`
- Password: `WaficWazzan!2`

## Management Interface

You can also run the web management interface:

```bash
# Install Python dependencies
pip install -r requirements.txt

# Run the management interface
python app.py
```

Then access http://localhost:5000 for web-based management.

## Troubleshooting

1. **Services not accessible**: Check if Docker is running and containers are healthy
2. **Domain issues**: Add entries to `/etc/hosts` for localhost domains
3. **Permission errors**: Run `./security-setup.sh` to fix file permissions
4. **Port conflicts**: Check if ports 80, 443, 5432, 6379 are available

## Production Deployment

For production deployment, see `PRODUCTION_GUIDE.md` for detailed instructions.

