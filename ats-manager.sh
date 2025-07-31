#!/bin/bash
# ATS Server Management Script
# Provides commands to manage the ATS game server with Docker Compose

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR:${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING:${NC} $1"
}

info() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] INFO:${NC} $1"
}

# Function to get Docker Compose command
get_compose_cmd() {
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        echo "docker compose"
    elif command -v docker-compose >/dev/null 2>&1; then
        echo "docker-compose"
    else
        echo ""
    fi
}

# Function to check if services are running
check_services() {
    local compose_cmd=$(get_compose_cmd)
    
    if [[ -z "$compose_cmd" ]]; then
        error "Docker Compose not available"
        return 1
    fi
    
    echo "📊 Service Status:"
    echo "=================="
    $compose_cmd ps
    echo ""
    
    echo "🔌 Port Status:"
    echo "==============="
    for port in 80 443 27015 3001 6379 19999; do
        if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
            echo "✅ Port $port: LISTENING"
        else
            echo "❌ Port $port: NOT LISTENING"
        fi
    done
    echo ""
    
    echo "💾 Resource Usage:"
    echo "=================="
    echo "Memory: $(free -h | grep '^Mem' | awk '{print $3"/"$2}')"
    echo "Disk: $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5" used)"}')"
    echo "Load: $(uptime | awk -F'load average:' '{print $2}' | xargs)"
}

# Function to show logs
show_logs() {
    local service="${1:-}"
    local compose_cmd=$(get_compose_cmd)
    
    if [[ -z "$compose_cmd" ]]; then
        error "Docker Compose not available"
        return 1
    fi
    
    if [[ -n "$service" ]]; then
        log "Showing logs for service: $service"
        $compose_cmd logs --tail=50 -f "$service"
    else
        log "Showing logs for all services"
        $compose_cmd logs --tail=20 -f
    fi
}

# Function to start services
start_services() {
    log "Starting ATS services..."
    
    if [[ ! -f ".env" ]]; then
        warn ".env file not found, creating default..."
        create_default_env
    fi
    
    local compose_cmd=$(get_compose_cmd)
    
    if [[ -z "$compose_cmd" ]]; then
        error "Docker Compose not available"
        return 1
    fi
    
    $compose_cmd up -d
    log "Services started successfully"
    
    sleep 10
    check_services
}

# Function to stop services
stop_services() {
    log "Stopping ATS services..."
    
    local compose_cmd=$(get_compose_cmd)
    
    if [[ -z "$compose_cmd" ]]; then
        error "Docker Compose not available"
        return 1
    fi
    
    $compose_cmd down
    log "Services stopped successfully"
}

# Function to restart services
restart_services() {
    log "Restarting ATS services..."
    stop_services
    sleep 5
    start_services
}

# Function to update services
update_services() {
    log "Updating ATS services..."
    
    local compose_cmd=$(get_compose_cmd)
    
    if [[ -z "$compose_cmd" ]]; then
        error "Docker Compose not available"
        return 1
    fi
    
    # Pull latest images
    log "Pulling latest images..."
    $compose_cmd pull
    
    # Rebuild if needed
    log "Building local images..."
    $compose_cmd build --no-cache
    
    # Restart with new images
    log "Restarting services with new images..."
    $compose_cmd up -d --force-recreate
    
    log "Services updated successfully"
    sleep 10
    check_services
}

# Function to create default environment file
create_default_env() {
    cat > .env << 'EOF'
# ATS Docker Compose Environment Configuration
NODE_ENV=production
TZ=America/Toronto

# ATS Game Server Configuration
ATS_SERVER_NAME="Freddy's ATS Server"
ATS_SERVER_PASSWORD=ruby
ATS_MAX_PLAYERS=8
ATS_SERVER_PORT=27015
ATS_QUERY_PORT=27016
ATS_WELCOME_MESSAGE="Welcome to Freddy's American Truck Simulator server!"
ATS_LOGON_TOKEN=
STEAM_COLLECTION_ID=3530633316
ATS_ENABLE_PVP=false
ATS_SPEED_LIMITER=true
ATS_FUEL_CONSUMPTION=1.0

# Web Interface Configuration
VITE_API_URL=http://localhost/api
VITE_SOCKET_URL=http://localhost

# API Server Configuration
JWT_SECRET=your-jwt-secret-change-this
FRONTEND_URL=http://localhost
ATS_DEFAULT_PASSWORD=ruby

# External Services
CLOUDFLARE_API_TOKEN=
CLOUDFLARE_ZONE_ID=
DOMAIN_NAME=ats.7gram.xyz
DISCORD_WEBHOOK_URL=
REDIS_URL=redis://redis:6379

# Monitoring
NETDATA_CLAIM_TOKEN=
NETDATA_CLAIM_URL=https://app.netdata.cloud
NETDATA_CLAIM_ROOMS=

# Docker Images
WEB_IMAGE=nuniesmith/ats:web-latest
API_IMAGE=nuniesmith/ats:api-latest
ATS_SERVER_IMAGE=nuniesmith/ats:server-latest
EOF
    
    log "Default .env file created"
}

# Function to show help
show_help() {
    echo ""
    echo "🎮 ATS Server Management Script"
    echo "================================"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start       Start all ATS services"
    echo "  stop        Stop all ATS services"
    echo "  restart     Restart all ATS services"
    echo "  status      Show service status and resource usage"
    echo "  logs        Show logs for all services"
    echo "  logs <svc>  Show logs for specific service"
    echo "  update      Update and restart services"
    echo "  deploy      Full deployment (same as running deploy-compose.sh)"
    echo "  env         Create default environment file"
    echo "  help        Show this help message"
    echo ""
    echo "Services:"
    echo "  ats-server  - ATS dedicated game server"
    echo "  ats-api     - Node.js API server"
    echo "  ats-web     - React web interface"
    echo "  redis       - Redis cache/session store"
    echo "  nginx       - Nginx reverse proxy"
    echo "  netdata     - Monitoring and metrics"
    echo ""
    echo "Examples:"
    echo "  $0 start                 # Start all services"
    echo "  $0 logs ats-server       # Show game server logs"
    echo "  $0 status                # Check service status"
    echo ""
}

# Main script logic
case "${1:-help}" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        check_services
        ;;
    logs)
        show_logs "${2:-}"
        ;;
    update)
        update_services
        ;;
    deploy)
        if [[ -f "deploy-compose.sh" ]]; then
            log "Running full deployment..."
            ./deploy-compose.sh
        else
            error "deploy-compose.sh not found"
            exit 1
        fi
        ;;
    env)
        create_default_env
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
