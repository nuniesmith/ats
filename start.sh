#!/bin/bash

# ATS Game Server - Simple Startup Script
# Defaults to pulling images from Docker Hub

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
ENV_FILE="$PROJECT_ROOT/.env"

# Docker Hub configuration
DOCKER_NAMESPACE="${DOCKER_NAMESPACE:-nuniesmith}"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-docker.io}"

# Environment detection
detect_environment() {
    # Check if we're in a cloud environment
    if [ -f /etc/cloud-id ] || [ -f /var/lib/cloud/data/instance-id ] || [ -n "$AWS_INSTANCE_ID" ] || [ -n "$GCP_PROJECT" ] || [ -n "$AZURE_SUBSCRIPTION_ID" ]; then
        echo "cloud"
        return
    fi
    
    # Check if we're in a container (dev server might be containerized)
    if [ -f /.dockerenv ] || [ -n "$KUBERNETES_SERVICE_HOST" ]; then
        echo "container"
        return
    fi
    
    # Check system resources to detect if we're on a resource-constrained environment
    if command -v free &> /dev/null; then
        local total_mem=$(free -m | awk '/^Mem:/{print $2}')
        if [ "$total_mem" -lt 4096 ]; then  # Less than 4GB RAM
            echo "resource_constrained"
            return
        fi
    fi
    
    # Check hostname patterns that might indicate a dev server
    local hostname=$(hostname)
    if [[ "$hostname" =~ (dev|staging|cloud|vps|server) ]]; then
        echo "dev_server"
        return
    fi
    
    # Check if we have a .laptop or .local file marker
    if [ -f "$HOME/.laptop" ] || [ -f "$PROJECT_ROOT/.local" ]; then
        echo "laptop"
        return
    fi
    
    # Default to cloud for ATS server deployment
    echo "cloud"
}

# Determine build strategy based on environment
DETECTED_ENV=$(detect_environment)
if [ -z "$BUILD_LOCAL" ]; then
    case "$DETECTED_ENV" in
        "cloud"|"container"|"resource_constrained"|"dev_server")
            BUILD_LOCAL="false"
            ;;
        "laptop")
            BUILD_LOCAL="true"
            ;;
        *)
            BUILD_LOCAL="false"
            ;;
    esac
fi

# Simple logging
log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        "DEBUG")
            echo -e "${BLUE}[DEBUG]${NC} $message"
            ;;
    esac
}

# Check prerequisites
check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log "ERROR" "Docker is not installed!"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log "ERROR" "Docker is not running!"
        exit 1
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        log "ERROR" "Docker Compose is not available!"
        exit 1
    fi
    
    log "INFO" "Prerequisites check passed"
}

# Create environment file
create_env_file() {
    log "INFO" "Creating environment file..."
    
    # Generate secure passwords
    MYSQL_ROOT_PASSWORD="ats_mysql_$(openssl rand -hex 8)"
    MYSQL_PASSWORD="ats_user_$(openssl rand -hex 8)"
    
    cat > "$ENV_FILE" << EOF
# ATS Game Server Environment
COMPOSE_PROJECT_NAME=ats
ENVIRONMENT=production
APP_ENV=production

# ATS Server Configuration
ATS_PORT=27015
ATS_QUERY_PORT=27016
ATS_HTTP_PORT=8080

# Database
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_DATABASE=ats_server
MYSQL_USER=ats_user
MYSQL_PASSWORD=$MYSQL_PASSWORD
MYSQL_PORT=3306

# Docker Hub
DOCKER_NAMESPACE=$DOCKER_NAMESPACE
DOCKER_REGISTRY=$DOCKER_REGISTRY

# Timezone
TZ=America/Toronto
EOF
    
    log "INFO" "Environment file created"
}

# Main function
main() {
    # Parse command line arguments first
    parse_args "$@"
    
    log "INFO" "🚛 Starting ATS Game Server..."
    
    # Show detected environment
    log "INFO" "🔍 Detected environment: $DETECTED_ENV"
    
    # Show build strategy
    if [ "$BUILD_LOCAL" = "true" ]; then
        log "INFO" "📦 Build strategy: LOCAL (building images on this machine)"
    else
        log "INFO" "📦 Build strategy: REMOTE (pulling from Docker Hub)"
    fi
    
    # Change to project directory
    cd "$PROJECT_ROOT"
    
    # Check prerequisites
    check_prerequisites
    
    # Create .env file if it doesn't exist
    if [ ! -f "$ENV_FILE" ]; then
        create_env_file
    else
        log "INFO" "Using existing .env file"
    fi
    
    # Stop existing services
    log "INFO" "Stopping existing services..."
    $COMPOSE_CMD down --remove-orphans 2>/dev/null || true
    
    # Fix Docker networking if needed
    log "INFO" "🔧 Checking Docker networking..."
    
    # For non-root users in docker group, we can't check iptables directly
    # Instead, we'll test Docker networking functionality
    if ! docker network ls >/dev/null 2>&1; then
        log "ERROR" "❌ Docker is not accessible. Please ensure Docker is running and you're in the docker group."
        exit 1
    fi
    
    # In GitHub Actions deployment, skip network creation test since networks are handled by the deployment workflow
    if [ -n "$GITHUB_ACTIONS" ] || [ "$USER" = "ats_user" ] || [ "$USER" = "root" ]; then
        log "INFO" "✅ Docker networking check skipped (deployment environment)"
    else
        # Test if we can create a test network (only for local environments)
        if ! docker network create --driver bridge test-network-$$$ >/dev/null 2>&1; then
            log "WARN" "⚠️ Docker networking appears to be broken."
            log "INFO" "🔧 Attempting to fix Docker networking without sudo..."
            
            # Stop all containers
            log "INFO" "Stopping all containers..."
            docker stop $(docker ps -aq) 2>/dev/null || true
            
            # Remove all containers
            docker rm $(docker ps -aq) 2>/dev/null || true
            
            # Clean up Docker networks
            log "INFO" "Cleaning up Docker networks..."
            docker network prune -f >/dev/null 2>&1 || true
            
            log "ERROR" "❌ Docker networking issues detected. This requires administrative privileges to fix."
            log "ERROR" "Please contact your system administrator to run:"
            log "ERROR" "  sudo systemctl restart docker"
            exit 1
        else
            # Remove the test network
            docker network rm test-network-$$$ >/dev/null 2>&1 || true
            log "INFO" "✅ Docker networking is properly configured"
        fi
    fi
    
    # Clean up any existing ats-network
    if docker network inspect ats-network >/dev/null 2>&1; then
        if [ -z "$(docker network inspect ats-network -f '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null)" ]; then
            log "INFO" "Removing existing ats-network to let docker-compose recreate it..."
            docker network rm ats-network 2>/dev/null || true
        fi
    fi
    
    # Docker login if credentials are available
    if [ -n "$DOCKER_USERNAME" ] && [ -n "$DOCKER_TOKEN" ]; then
        log "INFO" "🔐 Logging into Docker Hub..."
        echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USERNAME" --password-stdin
    fi
    
    # Determine build strategy
    if [ "$BUILD_LOCAL" = "true" ]; then
        log "INFO" "🏗️ Building images locally..."
        $COMPOSE_CMD build --parallel
    else
        log "INFO" "🐳 Pulling images from Docker Hub..."
        
        # Force pull latest images
        log "INFO" "🔄 Pulling latest images from Docker Hub..."
        if $COMPOSE_CMD pull --ignore-pull-failures 2>&1 | tee /tmp/docker-pull.log; then
            log "INFO" "✅ Images pulled successfully"
        else
            log "WARN" "⚠️ Failed to pull images, will build locally as fallback"
            log "INFO" "🏗️ Building images locally..."
            $COMPOSE_CMD build --parallel
        fi
    fi
    
    # Start services
    log "INFO" "🚀 Starting ATS Services..."
    $COMPOSE_CMD up -d
    
    # Wait for services to start
    log "INFO" "⏳ Waiting for services to initialize..."
    sleep 15
    
    # Show status
    log "INFO" "📊 Service status:"
    $COMPOSE_CMD ps
    
    # Test connectivity
    log "INFO" "🔌 Testing connectivity..."
    
    # Test ATS server port
    if netstat -ln | grep -q ":27015 "; then
        log "INFO" "✅ ATS server is listening on port 27015"
    else
        log "WARN" "⚠️ ATS server not yet listening on port 27015 (may still be starting)"
    fi
    
    # Test HTTP management port
    if curl -s -f http://localhost:8080 >/dev/null 2>&1; then
        log "INFO" "✅ ATS management interface is accessible at http://localhost:8080"
    else
        log "WARN" "⚠️ ATS management interface not yet accessible (may still be starting)"
    fi
    
    log "INFO" "🎉 ATS Game Server startup complete!"
    log "INFO" "🚛 Game Server: steam://connect/$(curl -s ifconfig.me):27015"
    log "INFO" "🔧 Management: http://localhost:8080"
    log "INFO" "📝 View logs: docker compose logs -f"
    log "INFO" "🛑 Stop services: docker compose down"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --set-laptop)
                touch "$PROJECT_ROOT/.local"
                log "INFO" "Created .local marker file. This environment will now be detected as 'laptop'."
                exit 0
                ;;
            --show-env)
                show_environment_info
                exit 0
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                echo "Use --help for usage information."
                exit 1
                ;;
        esac
    done
}

show_help() {
    echo "ATS Game Server Startup Script"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --help, -h          Show this help message"
    echo "  --set-laptop        Mark this environment as a laptop (creates .local file)"
    echo "  --show-env          Show detected environment and exit"
    echo ""
    echo "Environment Variables:"
    echo "  BUILD_LOCAL=true/false    Override automatic build strategy detection"
    echo "  DOCKER_NAMESPACE=name     Docker Hub namespace (default: nuniesmith)"
    echo "  DOCKER_REGISTRY=registry  Docker registry (default: docker.io)"
    echo "  DOCKER_USERNAME=user      Docker Hub username for login"
    echo "  DOCKER_TOKEN=token        Docker Hub token for login"
    echo ""
}

show_environment_info() {
    echo "Detected environment: $DETECTED_ENV"
    echo "Build strategy: $([ "$BUILD_LOCAL" = "true" ] && echo "LOCAL" || echo "REMOTE")"
    echo ""
    echo "System information:"
    if command -v free &> /dev/null; then
        echo "  Memory: $(free -m | awk '/^Mem:/{print $2}') MB"
    fi
    echo "  Hostname: $(hostname)"
    echo "  User: $USER"
    if [ -f "$PROJECT_ROOT/.local" ]; then
        echo "  .local marker: Present"
    else
        echo "  .local marker: Not found"
    fi
}

# Run main function
main "$@"
