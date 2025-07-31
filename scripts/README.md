# ATS Server Scripts Organization

This directory contains all the organized scripts for managing the ATS Server infrastructure, from local development to production deployment.

## 📁 Directory Structure

```
scripts/
├── docker/                    # Docker deployment scripts
│   ├── deploy-local.bat/.sh   # Local development deployment
│   └── deploy-dockerhub.bat/.sh # Production DockerHub deployment
├── deployment/                # Server deployment utilities
│   ├── create-ats-server.sh   # Linode server creation
│   └── deploy-ats-configs.sh  # Configuration deployment
├── ats_server_manager.bat     # Main ATS server management
├── env_manager.bat            # Environment configuration manager
├── load_env.bat               # Environment variable loader
├── mod_collection_utility.bat # Steam Workshop mod management
├── start_ats_server.sh        # ATS server startup script
└── test_env.bat               # Environment testing
```

## 🚀 Quick Start

### Option 1: Master Deployment Script (Recommended)
```bash
# From project root
./deploy.bat          # Windows interactive menu
./deploy.sh           # Linux interactive menu

# Or direct commands
./deploy.bat local start              # Local development
./deploy.bat dockerhub start prod     # Production deployment
```

### Option 2: Direct Script Usage
```bash
# Local development (builds images locally)
scripts/docker/deploy-local.bat start

# Production deployment (uses DockerHub images)
scripts/docker/deploy-dockerhub.bat start prod

# ATS game server management
scripts/ats_server_manager.bat
```

## 🔧 Script Categories

### Docker Deployment Scripts
- **`deploy-local.bat/.sh`** - Local development deployment
  - Builds Docker images from source
  - Perfect for development and testing
  - Uses `docker-compose.yml`

- **`deploy-dockerhub.bat/.sh`** - Production deployment
  - Pulls pre-built images from DockerHub
  - Supports version tags for rollbacks
  - Uses `docker-compose.prod.yml`

### Server Management Scripts
- **`ats_server_manager.bat`** - Comprehensive ATS server management
  - Start/stop ATS dedicated server
  - Mod collection management
  - Server configuration
  - Player management

- **`env_manager.bat`** - Environment configuration manager
  - Edit `.env` configuration
  - Backup/restore settings
  - Validate configuration

### Deployment Scripts
- **`create-ats-server.sh`** - Automated server creation on Linode
- **`deploy-ats-configs.sh`** - Deploy configurations to server

## 📝 Available Commands

### Deploy Local
```bash
deploy-local.bat {start|stop|restart|logs|status|build|cleanup}
```

### Deploy DockerHub
```bash
deploy-dockerhub.bat {start|stop|restart|build|logs|status|pull|update|cleanup} [prod] [version]
```

### Examples
```bash
# Start local development
scripts/docker/deploy-local.bat start

# Start production with specific version
scripts/docker/deploy-dockerhub.bat start prod v1.2.3

# View logs for specific service
scripts/docker/deploy-local.bat logs ats-web

# Update to latest production images
scripts/docker/deploy-dockerhub.bat update latest

# Clean up all resources
scripts/docker/deploy-local.bat cleanup
```

## 🔍 Health Checks

All deployment scripts include automated health checks:
- ✅ Web App: `http://localhost/health`
- ✅ API Server: `http://localhost:3001/health`
- ✅ Redis: Internal ping check

## 🌐 Access Points

After successful deployment:
- **Web Interface**: http://localhost
- **API Server**: http://localhost:3001
- **Management Dashboard**: Integrated in web interface

## 🛠️ Configuration

### Environment Variables
Scripts automatically create `.env` file with defaults:
```env
# Security
JWT_SECRET=your-jwt-secret-change-this-in-production

# Domain Configuration
DOMAIN_NAME=ats.7gram.xyz

# ATS Configuration
ATS_DEFAULT_PASSWORD=ruby
STEAM_COLLECTION_ID=3530633316

# Optional External Services
CLOUDFLARE_API_TOKEN=
CLOUDFLARE_ZONE_ID=
DISCORD_WEBHOOK_URL=
```

### DockerHub Images
For production deployment, set in `.env`:
```env
WEB_IMAGE=nuniesmith/ats:web-latest
API_IMAGE=nuniesmith/ats:api-latest
```

## 🔄 CI/CD Integration

The GitHub Actions workflow (`.github/workflows/ats-deploy.yml`) automatically:
1. **Builds** Docker images and pushes to DockerHub
2. **Creates** Linode servers (if requested)
3. **Deploys** complete Docker stack
4. **Updates** DNS records via Cloudflare
5. **Sends** Discord notifications

### Required GitHub Secrets
```
LINODE_CLI_TOKEN              # Linode API token
ATS_ROOT_PASSWORD         # Server root password
DOCKERHUB_USERNAME        # DockerHub username
DOCKERHUB_TOKEN           # DockerHub access token
JWT_SECRET                # JWT secret for API
ATS_DEFAULT_PASSWORD      # Default ATS server password
CLOUDFLARE_API_TOKEN      # Cloudflare API token (optional)
CLOUDFLARE_ZONE_ID        # Cloudflare zone ID (optional)
DISCORD_WEBHOOK_URL       # Discord webhook URL (optional)
```

## 📋 Troubleshooting

### Common Issues

1. **Docker not found**
   ```bash
   # Install Docker Desktop (Windows) or Docker Engine (Linux)
   # Ensure Docker Compose is available
   ```

2. **Permission denied**
   ```bash
   # Linux: Make scripts executable
   chmod +x scripts/docker/*.sh
   chmod +x deploy.sh
   ```

3. **Port conflicts**
   ```bash
   # Check what's using ports 80, 3001, 6379
   netstat -tulpn | grep :80
   ```

4. **Health checks failing**
   ```bash
   # Check container logs
   scripts/docker/deploy-local.bat logs
   
   # Check service status
   scripts/docker/deploy-local.bat status
   ```

### Log Locations
- **Container Logs**: `docker-compose logs`
- **Application Logs**: `volumes/ats-logs/`
- **Nginx Logs**: `volumes/nginx-logs/`

## 🎯 Best Practices

1. **Use environment-specific configs**
   - Local: Use `deploy-local.bat` for development
   - Production: Use `deploy-dockerhub.bat` with version tags

2. **Version your deployments**
   ```bash
   # Tag releases for rollbacks
   scripts/docker/deploy-dockerhub.bat start prod v1.2.3
   ```

3. **Monitor health**
   ```bash
   # Regular health checks
   scripts/docker/deploy-local.bat status
   ```

4. **Backup configurations**
   ```bash
   # Use environment manager
   scripts/env_manager.bat
   ```

## 📞 Support

- **Scripts Help**: Run any script without arguments for usage
- **Health Checks**: All scripts include built-in health monitoring
- **Logs**: Use `logs` command with any deployment script
- **Documentation**: Check `docs/` folder for detailed guides

---

**🎮 Happy ATS Server Management!** 🚛
