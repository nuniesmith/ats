#!/bin/bash

# ATS Server Docker Deployment Script with DockerHub Support
# ==========================================================

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"
PROD_COMPOSE_FILE="$PROJECT_ROOT/docker-compose.prod.yml"
ENV_FILE="$PROJECT_ROOT/.env"
DOCKERHUB_REPO="nuniesmith/ats"

# Change to project root
cd "$PROJECT_ROOT"

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

check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
}

check_environment() {
    if [[ ! -f "$ENV_FILE" ]]; then
        log_warning "Environment file .env not found. Creating with defaults..."
        create_env_file
    fi
}

create_env_file() {
    cat > "$ENV_FILE" << EOF
# ATS Server Configuration
NODE_ENV=production
JWT_SECRET=your-jwt-secret-change-this-in-production
DOMAIN_NAME=ats.7gram.xyz
ATS_DEFAULT_PASSWORD=ruby
STEAM_COLLECTION_ID=3530633316

# DockerHub Images (leave empty to build locally)
WEB_IMAGE=
API_IMAGE=

# Optional External Services
CLOUDFLARE_API_TOKEN=
CLOUDFLARE_ZONE_ID=
DISCORD_WEBHOOK_URL=
EOF
    log_success "Created default environment file: .env"
    log_info "Please edit .env with your configuration"
}

pull_images() {
    local tag=${1:-latest}
    
    log_info "Pulling Docker images from DockerHub..."
    
    if docker pull "$DOCKERHUB_REPO:web-$tag" 2>/dev/null; then
        export WEB_IMAGE="$DOCKERHUB_REPO:web-$tag"
        log_success "Pulled web image: $WEB_IMAGE"
    else
        log_warning "Failed to pull web image, will build locally"
        export WEB_IMAGE=""
    fi
    
    if docker pull "$DOCKERHUB_REPO:api-$tag" 2>/dev/null; then
        export API_IMAGE="$DOCKERHUB_REPO:api-$tag"
        log_success "Pulled API image: $API_IMAGE"
    else
        log_warning "Failed to pull API image, will build locally"
        export API_IMAGE=""
    fi
}

build_images() {
    log_info "Building Docker images locally..."
    docker-compose -f "$COMPOSE_FILE" build --no-cache
    log_success "Docker images built successfully"
}

start_services() {
    local use_prod=${1:-false}
    local tag=${2:-latest}
    
    check_docker
    check_environment
    
    if [[ "$use_prod" == "true" ]]; then
        log_info "Starting services with production configuration..."
        pull_images "$tag"
        WEB_IMAGE="$WEB_IMAGE" API_IMAGE="$API_IMAGE" docker-compose -f "$PROD_COMPOSE_FILE" up -d
    else
        log_info "Starting services with local configuration..."
        docker-compose -f "$COMPOSE_FILE" up -d
    fi
    
    log_success "Services started successfully"
    show_status
}

stop_services() {
    log_info "Stopping all services..."
    docker-compose -f "$COMPOSE_FILE" down
    if [[ -f "$PROD_COMPOSE_FILE" ]]; then
        docker-compose -f "$PROD_COMPOSE_FILE" down 2>/dev/null || true
    fi
    log_success "All services stopped"
}

restart_services() {
    local use_prod=${1:-false}
    local tag=${2:-latest}
    
    log_info "Restarting services..."
    stop_services
    sleep 2
    start_services "$use_prod" "$tag"
}

show_logs() {
    local service=${1:-}
    
    if [[ -n "$service" ]]; then
        log_info "Showing logs for service: $service"
        docker-compose -f "$COMPOSE_FILE" logs -f "$service"
    else
        log_info "Showing logs for all services..."
        docker-compose -f "$COMPOSE_FILE" logs -f
    fi
}

show_status() {
    log_info "Service Status:"
    docker-compose -f "$COMPOSE_FILE" ps
    
    echo ""
    log_info "Health Checks:"
    
    # Check web app health
    if curl -sf http://localhost/health >/dev/null 2>&1; then
        log_success "Web App: Healthy (http://localhost)"
    else
        log_error "Web App: Unhealthy or not accessible"
    fi
    
    # Check API health
    if curl -sf http://localhost:3001/health >/dev/null 2>&1; then
        log_success "API Server: Healthy (http://localhost:3001)"
    else
        log_error "API Server: Unhealthy or not accessible"
    fi
    
    # Check Redis
    if docker-compose -f "$COMPOSE_FILE" exec -T redis redis-cli ping >/dev/null 2>&1; then
        log_success "Redis: Healthy"
    else
        log_error "Redis: Unhealthy or not accessible"
    fi
}

cleanup() {
    log_warning "This will remove all containers, networks, and unused images"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Cleaning up Docker resources..."
        docker-compose down --volumes --remove-orphans
        if [[ -f "$PROD_COMPOSE_FILE" ]]; then
            docker-compose -f "$PROD_COMPOSE_FILE" down --volumes --remove-orphans || true
        fi
        docker system prune -f
        log_success "Cleanup completed"
    else
        log_info "Cleanup cancelled"
    fi
}

update_images() {
    local tag=${1:-latest}
    
    log_info "Updating to latest images..."
    pull_images "$tag"
    
    if [[ -n "$WEB_IMAGE" ]] && [[ -n "$API_IMAGE" ]]; then
        restart_services true "$tag"
    else
        restart_services false
    fi
}

show_help() {
    echo "ATS Server Docker Deployment Script with DockerHub Support"
    echo "=========================================================="
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  start [prod] [tag]    Start services (prod=use DockerHub images)"
    echo "  stop                  Stop all services"
    echo "  restart [prod] [tag]  Restart services"
    echo "  build                 Build Docker images locally"
    echo "  logs [service]        Show logs (optionally for specific service)"
    echo "  status                Show service status and health"
    echo "  pull [tag]            Pull images from DockerHub"
    echo "  update [tag]          Update to latest images and restart"
    echo "  cleanup               Remove all containers and unused resources"
    echo "  help                  Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start              # Start with local images"
    echo "  $0 start prod         # Start with DockerHub images (latest)"
    echo "  $0 start prod v1.2.3  # Start with specific version"
    echo "  $0 logs ats-web       # Show logs for web service"
    echo "  $0 update v1.2.3      # Update to specific version"
    echo ""
    echo "DockerHub Repository: $DOCKERHUB_REPO"
}

# Main script logic
case "${1:-}" in
    "start")
        start_services "${2:-false}" "${3:-latest}"
        ;;
    "stop")
        stop_services
        ;;
    "restart")
        restart_services "${2:-false}" "${3:-latest}"
        ;;
    "build")
        check_docker
        build_images
        ;;
    "logs")
        show_logs "${2:-}"
        ;;
    "status")
        show_status
        ;;
    "pull")
        check_docker
        pull_images "${2:-latest}"
        ;;
    "update")
        update_images "${2:-latest}"
        ;;
    "cleanup")
        cleanup
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
