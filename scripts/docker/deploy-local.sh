#!/bin/bash

# ATS Server Local Docker Deployment Script
# ==========================================

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"
ENV_FILE="$PROJECT_ROOT/.env"

# Change to project root
cd "$PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is installed
check_docker() {
    log_info "Checking Docker installation..."
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    log_success "Docker and Docker Compose are installed"
}

# Create environment file if it doesn't exist
create_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        log_warning "Environment file .env not found. Creating with defaults..."
        cat > "$ENV_FILE" << 'EOF'
# ATS Server Environment Configuration
# ===================================

# Security
JWT_SECRET=your-jwt-secret-change-this-in-production

# Domain Configuration
DOMAIN_NAME=ats.7gram.xyz

# ATS Configuration
ATS_DEFAULT_PASSWORD=ruby
STEAM_COLLECTION_ID=3530633316

# API URLs (automatically configured for Docker)
VITE_API_URL=http://localhost/api
VITE_SOCKET_URL=http://localhost

# Optional: External Services
CLOUDFLARE_API_TOKEN=
CLOUDFLARE_ZONE_ID=
DISCORD_WEBHOOK_URL=
EOF
        log_warning "Created .env file - please edit it with your configuration"
        log_info "You can start with default values for local development"
    else
        log_info "Using existing .env file"
    fi
}

# Build Docker images
build_images() {
    log_info "Building Docker images locally..."
    docker-compose build --no-cache
    log_success "Docker images built successfully"
}

# Start services
start_services() {
    log_info "Starting ATS services..."
    
    # Stop any existing containers
    docker-compose down || true
    
    # Start new containers
    docker-compose up -d
    
    log_success "Services started successfully"
}

# Check service health
check_health() {
    log_info "Checking service health..."
    
    # Wait for services to start
    sleep 10
    
    # Check if containers are running
    if docker-compose ps | grep -q "Up"; then
        log_success "Containers are running"
    else
        log_error "Some containers failed to start"
        docker-compose logs
        exit 1
    fi
    
    # Check web app health
    log_info "Checking web application health..."
    for i in {1..30}; do
        if curl -f http://localhost/health &> /dev/null; then
            log_success "Web application is healthy"
            break
        fi
        log_info "Waiting for web application... (attempt $i/30)"
        sleep 2
    done
    
    # Check API health
    log_info "Checking API server health..."
    for i in {1..30}; do
        if curl -f http://localhost:3001/health &> /dev/null; then
            log_success "API server is healthy"
            break
        fi
        log_info "Waiting for API server... (attempt $i/30)"
        sleep 2
    done
}

# Show deployment info
show_info() {
    echo ""
    log_success "🚀 ATS Server Management System is running!"
    echo ""
    echo "📍 Access Points:"
    echo "   🌐 Web Interface: http://localhost"
    echo "   🔧 API Server: http://localhost:3001"
    echo "   📊 Health Check: http://localhost/health"
    echo ""
    echo "🔧 Management Commands:"
    echo "   📋 View logs: $0 logs"
    echo "   📊 View status: $0 status"
    echo "   🛑 Stop services: $0 stop"
    echo "   🔄 Restart services: $0 restart"
    echo ""
    echo "🔐 Default Login:"
    echo "   👤 Username: admin"
    echo "   🔑 Password: admin123"
    echo ""
}

# Show logs
show_logs() {
    local service=${1:-}
    
    if [[ -n "$service" ]]; then
        log_info "Showing logs for service: $service"
        docker-compose logs --tail=50 -f "$service"
    else
        log_info "Showing container logs..."
        docker-compose logs --tail=50 -f
    fi
}

# Stop services
stop_services() {
    log_info "Stopping ATS services..."
    docker-compose down
    log_success "Services stopped"
}

# Restart services
restart_services() {
    log_info "Restarting ATS services..."
    docker-compose down
    docker-compose up -d
    check_health
    show_info
}

# Clean up (remove containers and images)
cleanup() {
    log_warning "This will remove all containers, networks, and unused images"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Cleaning up Docker resources..."
        docker-compose down --volumes --remove-orphans
        docker rmi ats-web:latest ats-api:latest 2>/dev/null || true
        log_success "Cleanup completed"
    else
        log_info "Cleanup cancelled"
    fi
}

# Show status
show_status() {
    log_info "Service Status:"
    docker-compose ps
    
    echo ""
    log_info "Quick Health Check:"
    
    # Check web app health
    if curl -sf http://localhost/health >/dev/null 2>&1; then
        log_success "Web App: Healthy"
    else
        log_error "Web App: Unhealthy"
    fi
    
    # Check API health
    if curl -sf http://localhost:3001/health >/dev/null 2>&1; then
        log_success "API Server: Healthy"
    else
        log_error "API Server: Unhealthy"
    fi
}

# Show help
show_help() {
    echo "ATS Server Local Docker Deployment Script"
    echo "=========================================="
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  start      - Build and start all services"
    echo "  stop       - Stop all services"
    echo "  restart    - Restart all services"
    echo "  logs [svc] - Show container logs (optionally for specific service)"
    echo "  build      - Build Docker images only"
    echo "  cleanup    - Stop services and remove containers/images"
    echo "  status     - Show container status and health"
    echo "  help       - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start           # Start everything"
    echo "  $0 logs ats-web    # Show web app logs"
    echo "  $0 status          # Check service health"
    echo ""
}

# Main script logic
case "${1:-}" in
    "start")
        check_docker
        create_env_file
        build_images
        start_services
        check_health
        show_info
        ;;
    "stop")
        stop_services
        ;;
    "restart")
        restart_services
        ;;
    "logs")
        show_logs "${2:-}"
        ;;
    "build")
        check_docker
        build_images
        ;;
    "cleanup")
        cleanup
        ;;
    "status")
        show_status
        ;;
    "help"|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
