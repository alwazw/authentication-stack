# Docker Authentication Stack Architecture

## 🏗️ System Overview

This Docker stack implements a modern, secure authentication infrastructure with enterprise-grade components:

- **Traefik v3.0**: Edge router with automatic SSL and service discovery
- **Authentik 2024.2.2**: Identity provider with OAuth2/OIDC/SAML support
- **PostgreSQL 15**: Primary database with Alpine Linux base
- **Redis 7**: Session storage and caching layer
- **pgAdmin 4**: Database administration with direct port access

## 🌐 Network Architecture

```
Internet/LAN
     ↓
┌─────────────────────────────────────────────────────────────┐
│                    Traefik (Port 80/443)                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   SSL/TLS       │  │  Load Balancer  │  │   Router    │ │
│  │  Termination    │  │   & Discovery   │  │   Rules     │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
     ↓                           ↓                    ↓
┌─────────────┐         ┌─────────────────┐    ┌─────────────┐
│  Authentik  │         │   Dashboard     │    │   pgAdmin   │
│   (Port 9000) │         │   (/dashboard)  │    │ (Port 5050) │
│             │         │                 │    │             │
│ ┌─────────┐ │         └─────────────────┘    │ ┌─────────┐ │
│ │ Server  │ │                                │ │  Web    │ │
│ │ Worker  │ │                                │ │  UI     │ │
│ └─────────┘ │                                │ └─────────┘ │
└─────────────┘                                └─────────────┘
     ↓                                                ↓
┌─────────────────────────────────────────────────────────────┐
│                    Backend Services                         │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │   PostgreSQL    │              │      Redis      │      │
│  │   (Port 5432)   │              │   (Port 6379)   │      │
│  │                 │              │                 │      │
│  │ ┌─────────────┐ │              │ ┌─────────────┐ │      │
│  │ │ Database    │ │              │ │   Cache     │ │      │
│  │ │ Storage     │ │              │ │  Sessions   │ │      │
│  │ └─────────────┘ │              │ └─────────────┘ │      │
│  └─────────────────┘              └─────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Authentication Flow

### Standard User Access
```
1. User → https://domain.com/
2. Traefik → Forward to Authentik
3. Authentik → Present login form
4. User → Submit credentials
5. Authentik → Validate & create session
6. Authentik → Redirect to requested service
7. Traefik → Forward authenticated request
8. Service → Serve protected content
```

### Service-to-Service Communication
```
1. Authentik Server ←→ PostgreSQL (User data, configuration)
2. Authentik Server ←→ Redis (Sessions, cache)
3. Authentik Worker ←→ PostgreSQL (Background tasks)
4. Authentik Worker ←→ Redis (Task queue)
5. pgAdmin ←→ PostgreSQL (Database administration)
```

## 🌐 Network Topology

### Docker Networks
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  traefik        │    │   authentik     │    │   database      │
│                 │    │                 │    │                 │
│ • traefik       │    │ • authentik-    │    │ • postgresql    │
│ • authentik-    │    │   server        │    │ • pgadmin       │
│   server        │    │ • authentik-    │    │                 │
│                 │    │   worker        │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘

┌─────────────────┐
│     cache       │
│                 │
│ • redis         │
│ • authentik-    │
│   server        │
│ • authentik-    │
│   worker        │
└─────────────────┘
```

### Network Isolation
- **traefik**: External access and routing
- **authentik**: Authentication service communication
- **database**: Database access (PostgreSQL + pgAdmin)
- **cache**: Redis caching and sessions

## 🔒 Security Architecture

### Authentication Layers
```
┌─────────────────────────────────────────────────────────────┐
│                    Security Layers                          │
├─────────────────────────────────────────────────────────────┤
│ 1. Network Security (Docker Networks + Firewall)           │
├─────────────────────────────────────────────────────────────┤
│ 2. SSL/TLS Termination (Traefik + Let's Encrypt)          │
├─────────────────────────────────────────────────────────────┤
│ 3. Forward Authentication (Traefik → Authentik)           │
├─────────────────────────────────────────────────────────────┤
│ 4. Identity Provider (Authentik OAuth2/OIDC/SAML)         │
├─────────────────────────────────────────────────────────────┤
│ 5. Application Security (Service-level permissions)        │
└─────────────────────────────────────────────────────────────┘
```

### Secrets Management
```
Environment Variables (.env)
├── Non-sensitive configuration
├── Service discovery settings
└── Domain and email configuration

Docker Secrets (secrets/)
├── Database passwords
├── Redis authentication
├── Authentik secret keys
└── SSL certificate data

File Permissions
├── .env (600) - Owner read/write only
├── secrets/ (700) - Owner access only
└── config/ (755) - Standard directory permissions
```

## 📊 Service Dependencies

### Startup Order
```
1. PostgreSQL (Database foundation)
2. Redis (Cache and sessions)
3. Traefik (Routing and SSL)
4. Authentik Server (Authentication service)
5. Authentik Worker (Background processing)
6. pgAdmin (Database administration)
```

### Health Dependencies
```
Authentik Server:
├── Requires: PostgreSQL (healthy)
├── Requires: Redis (healthy)
└── Provides: Authentication API

Authentik Worker:
├── Requires: PostgreSQL (healthy)
├── Requires: Redis (healthy)
└── Provides: Background task processing

pgAdmin:
├── Requires: PostgreSQL (healthy)
└── Provides: Database administration

Traefik:
├── Requires: Docker socket access
└── Provides: Routing and SSL termination
```

## 🔧 Configuration Architecture

### Environment-Based Configuration
```
Production Environment:
├── .env (Environment variables)
├── config/ (Service configurations)
│   ├── traefik/dynamic.yml (Routing rules)
│   ├── postgresql/init.sql (Database setup)
│   └── pgadmin/servers.json (Server definitions)
└── secrets/ (Sensitive data)
    ├── postgres_password.txt
    ├── redis_password.txt
    └── authentik_secret.txt
```

### Service Configuration Sources
```
Traefik:
├── Command-line arguments (docker-compose.yml)
├── Dynamic configuration (config/traefik/dynamic.yml)
└── Docker labels (service discovery)

Authentik:
├── Environment variables (.env)
├── Database configuration (PostgreSQL)
└── Runtime configuration (Admin UI)

PostgreSQL:
├── Environment variables (.env)
├── Initialization scripts (config/postgresql/)
└── Runtime configuration (postgresql.conf)
```

## 🚀 Scalability Architecture

### Horizontal Scaling Points
```
Load Balancer (Traefik):
├── Multiple Traefik instances
├── External load balancer
└── Geographic distribution

Authentication (Authentik):
├── Multiple server instances
├── Increased worker instances
└── Session clustering via Redis

Database (PostgreSQL):
├── Read replicas
├── Connection pooling
└── Partitioning strategies

Cache (Redis):
├── Redis Cluster
├── Redis Sentinel
└── Memory optimization
```

### Performance Optimization
```
Database Layer:
├── Connection pooling
├── Query optimization
├── Index management
└── Backup strategies

Cache Layer:
├── Session storage
├── Query result caching
├── Static content caching
└── Memory management

Application Layer:
├── Worker scaling
├── Background task optimization
├── API rate limiting
└── Resource monitoring
```

## 📈 Monitoring Architecture

### Health Check Strategy
```
Service Health:
├── PostgreSQL: pg_isready command
├── Redis: redis-cli ping
├── Authentik: HTTP health endpoint
└── Traefik: API endpoint monitoring

Application Health:
├── Authentication flow testing
├── Database connectivity
├── Cache performance
└── SSL certificate validity
```

### Logging Architecture
```
Log Sources:
├── Traefik: Access logs, error logs
├── Authentik: Application logs, audit logs
├── PostgreSQL: Database logs, slow queries
├── Redis: Command logs, memory usage
└── System: Docker logs, host metrics

Log Aggregation:
├── Docker log drivers
├── Centralized logging (optional)
├── Log rotation policies
└── Retention strategies
```

## 🔄 Data Flow Patterns

### User Authentication Data Flow
```
1. User credentials → Authentik Server
2. Authentik Server → PostgreSQL (user lookup)
3. PostgreSQL → Authentik Server (user data)
4. Authentik Server → Redis (session creation)
5. Redis → Authentik Server (session confirmation)
6. Authentik Server → User (authentication token)
```

### Database Administration Data Flow
```
1. Admin → pgAdmin (port 5050)
2. pgAdmin → PostgreSQL (direct connection)
3. PostgreSQL → pgAdmin (query results)
4. pgAdmin → Admin (formatted data)
```

### Service Discovery Data Flow
```
1. Docker → Traefik (container events)
2. Traefik → Service labels (configuration)
3. Traefik → Routing table (updates)
4. Traefik → Load balancer (traffic distribution)
```

---

## 🎯 Architecture Benefits

### Security
- **Zero Trust**: All services require authentication
- **Network Isolation**: Services communicate on isolated networks
- **Secrets Management**: Sensitive data properly secured
- **SSL/TLS**: End-to-end encryption

### Scalability
- **Microservices**: Independent service scaling
- **Load Balancing**: Automatic traffic distribution
- **Service Discovery**: Dynamic service registration
- **Health Monitoring**: Automatic failure recovery

### Maintainability
- **Configuration Management**: Environment-based configuration
- **Logging**: Centralized log collection
- **Monitoring**: Built-in health checks
- **Updates**: Rolling deployment support

This architecture provides a robust, secure, and scalable foundation for enterprise authentication and database management needs.

