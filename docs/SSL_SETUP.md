# ATS SSL Setup Documentation

This document describes the SSL certificate management system for the ATS (American Truck Simulator) Game Server web interface.

## Overview

The ATS SSL system provides:
- **Self-signed certificates** as fallback for immediate HTTPS availability
- **Let's Encrypt certificates** as the primary SSL solution with automatic renewal
- **Systemd integration** for automated certificate management
- **Docker integration** with the existing ATS game server infrastructure

## Architecture

```
ATS SSL Management System
├── scripts/
│   ├── ssl-manager.sh          # Main SSL management script
│   └── install-ssl-systemd.sh  # Systemd service installer
├── ssl/
│   ├── self-signed/            # Self-signed certificates
│   ├── letsencrypt/            # Let's Encrypt certificates
│   ├── server.crt             # Active certificate (symlink)
│   ├── server.key             # Active private key (symlink)
│   └── dhparam.pem            # Diffie-Hellman parameters
├── config/
│   ├── nginx/
│   │   └── conf.d/
│   │       ├── ssl.conf       # SSL configuration
│   │       └── default.conf   # Server configuration
│   └── certbot/               # Certbot configuration
└── docker-compose.yml         # Updated with SSL volumes
```

## Quick Start

### 1. Initial SSL Setup
```bash
# Run the SSL manager to set up certificates
./scripts/ssl-manager.sh setup

# Install systemd services for automatic renewal
sudo ./scripts/install-ssl-systemd.sh
```

### 2. Configure Environment Variables
```bash
# Set in .env file or environment
DOMAIN_NAME=ats.7gram.xyz
LETSENCRYPT_EMAIL=admin@7gram.xyz

# Optional: For DNS challenge (wildcard certificates)
CLOUDFLARE_EMAIL=your-email@example.com
CLOUDFLARE_API_TOKEN=your-cloudflare-api-token
```

### 3. Start Services
```bash
# Start the ATS services with SSL
docker-compose up -d

# Enable automatic SSL renewal
sudo ats-ssl start
```

## SSL Manager Commands

The `ssl-manager.sh` script supports several commands:

```bash
# Initial setup with automatic fallback
./scripts/ssl-manager.sh setup

# Force renewal of existing certificates
./scripts/ssl-manager.sh renew

# Generate only self-signed certificates
./scripts/ssl-manager.sh self-signed

# Generate only Let's Encrypt certificates
./scripts/ssl-manager.sh letsencrypt

# Show certificate status and details
./scripts/ssl-manager.sh status

# Show help
./scripts/ssl-manager.sh help
```

## Systemd Management

After running the installer, use the `ats-ssl` command:

```bash
# Check status of SSL services and certificates
ats-ssl status

# Start automatic renewal (runs twice daily at 3:00 AM/PM)
sudo ats-ssl start

# Stop automatic renewal
sudo ats-ssl stop

# Force certificate renewal now
sudo ats-ssl renew

# View recent logs
ats-ssl logs
```

## Configuration Files

### SSL Configuration (`config/nginx/conf.d/ssl.conf`)
- Modern TLS 1.2/1.3 configuration
- Security headers optimized for gaming platforms
- OCSP stapling for improved performance
- CSP headers allowing game-related resources

### Server Configuration (`config/nginx/conf.d/default.conf`)
- HTTP to HTTPS redirection
- ACME challenge support for Let's Encrypt
- Proxy configuration for ATS API endpoints
- WebSocket support for real-time server status
- File upload handling for game mods

### Docker Compose Updates
- SSL certificate volume mounting: `./ssl:/opt/ats/ssl:ro`
- Certbot webroot: `/var/www/certbot:/var/www/certbot:ro`
- Nginx configuration: `./config/nginx/conf.d:/etc/nginx/conf.d:ro`

## Certificate Types

### Self-Signed Certificates
- Generated automatically as fallback
- 4096-bit RSA keys for enhanced security
- Valid for 365 days
- Subject Alternative Names for multiple domains
- Located in `ssl/self-signed/`

### Let's Encrypt Certificates
- Preferred certificate type
- Automatic renewal every 60 days
- Supports both HTTP-01 and DNS-01 challenges
- 90-day validity with automatic renewal
- Located in `ssl/letsencrypt/`

## Security Features

### SSL Configuration
- TLS 1.2/1.3 only
- Strong cipher suites (ECDHE preferred)
- Perfect Forward Secrecy
- HSTS with preload
- Secure session management

### Systemd Security
- NoNewPrivileges=true
- ProtectSystem=strict
- Restricted read/write paths
- CPU and memory limits
- Non-root execution where possible

### Gaming-Specific Headers
- CSP allowing game resources and APIs
- X-Game-Server identification
- Performance headers for monitoring
- Robots.txt to prevent indexing

## Monitoring and Logging

### Logs Location
- SSL Manager: `/var/log/ats-ssl-manager.log`
- Systemd logs: `journalctl -u ats-ssl-manager`
- Nginx logs: Docker volume `nginx-logs`

### Health Checks
- Certificate expiry monitoring (30-day threshold)
- Nginx configuration validation
- Service status checks
- Automatic renewal on expiry

## Troubleshooting

### Common Issues

#### 1. Let's Encrypt HTTP-01 Challenge Fails
```bash
# Check domain accessibility
dig ats.7gram.xyz
curl -I http://ats.7gram.xyz/.well-known/acme-challenge/test

# Ensure port 80 is accessible
sudo netstat -tulpn | grep :80
```

#### 2. Certificate Not Loading
```bash
# Check certificate files
ls -la ssl/
./scripts/ssl-manager.sh status

# Test nginx configuration
docker-compose exec nginx nginx -t
```

#### 3. Systemd Service Issues
```bash
# Check service status
systemctl status ats-ssl-manager
ats-ssl logs

# Manual renewal test
sudo ./scripts/ssl-manager.sh renew
```

### Manual Certificate Generation

#### Self-Signed Only
```bash
# Generate self-signed certificate
DOMAIN_NAME=ats.7gram.xyz ./scripts/ssl-manager.sh self-signed
```

#### Let's Encrypt with DNS Challenge
```bash
# Set Cloudflare credentials
export CLOUDFLARE_EMAIL=your-email@example.com
export CLOUDFLARE_API_TOKEN=your-api-token

# Generate certificate
./scripts/ssl-manager.sh letsencrypt
```

## Integration with ATS Services

### Web Interface
- Accessible at: `https://ats.7gram.xyz`
- Automatic HTTP to HTTPS redirection
- Session management with secure cookies

### API Endpoints
- Base URL: `https://ats.7gram.xyz/api/`
- WebSocket: `wss://ats.7gram.xyz/ws/`
- Authentication headers preserved

### Game Server Management
- Server status: `https://ats.7gram.xyz/status`
- Metrics: `https://ats.7gram.xyz/metrics`
- Logs: `https://ats.7gram.xyz/logs` (password protected)

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOMAIN_NAME` | `ats.7gram.xyz` | Primary domain for certificates |
| `LETSENCRYPT_EMAIL` | `admin@7gram.xyz` | Email for Let's Encrypt registration |
| `CLOUDFLARE_EMAIL` | - | Cloudflare account email (optional) |
| `CLOUDFLARE_API_TOKEN` | - | Cloudflare API token (optional) |

## Renewal Schedule

The systemd timer runs certificate renewal checks:
- **Schedule**: Twice daily at 3:00 AM and 3:00 PM
- **Randomization**: ±30 minutes to prevent load spikes
- **Offset**: 1 hour after nginx (2:00) and 30 minutes after FKS (2:30)
- **Persistence**: Catches up on missed runs after system reboot

## Security Considerations

### Certificate Storage
- Private keys have 600 permissions (owner read/write only)
- Certificates have 644 permissions (world readable)
- Separate directories for different certificate types

### Access Control
- Log viewing requires authentication
- Metrics endpoint can be restricted by IP
- Admin functions require sudo access

### Network Security
- All HTTP traffic redirected to HTTPS
- Secure headers prevent common attacks
- HSTS prevents protocol downgrade attacks

## Backup and Recovery

### Certificate Backup
```bash
# Backup SSL directory
tar -czf ats-ssl-backup-$(date +%Y%m%d).tar.gz ssl/

# Restore from backup
tar -xzf ats-ssl-backup-*.tar.gz
```

### Recovery Process
1. Restore SSL directory from backup
2. Run `./scripts/ssl-manager.sh status` to verify
3. Restart nginx: `docker-compose restart nginx`
4. Check service health: `ats-ssl status`

## Performance Optimization

### Certificate Caching
- Nginx session cache: 50MB shared cache
- Session timeout: 1 day
- OCSP stapling enabled for faster handshakes

### Static Asset Caching
- Game assets cached for 1 year
- Proper ETag headers
- Gzip compression enabled

## Updates and Maintenance

### SSL Manager Updates
```bash
# Update SSL manager script
git pull origin main
chmod +x scripts/ssl-manager.sh

# Test with status command
./scripts/ssl-manager.sh status
```

### Certificate Rotation
- Automatic renewal 30 days before expiry
- Zero-downtime rotation with symlinks
- Automatic nginx reload after renewal

## Related Documentation

- [ATS Game Server Setup](../README.md)
- [Docker Deployment Guide](../docs/DEPLOYMENT.md)
- [Nginx SSL Setup](../../nginx/docs/SSL_SETUP.md)
- [FKS SSL Setup](../../fks/docs/SSL_SETUP.md)
