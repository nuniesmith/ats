#!/bin/bash

# ATS Server Master Deployment Script
# ===================================

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_SCRIPTS_DIR="$SCRIPT_DIR/scripts/docker"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "==============================================="
echo "   ATS Server Management - Master Deployer"
echo "==============================================="
echo ""

# Check for command line argument
if [ $# -eq 0 ]; then
    show_menu
    exit 0
fi

# Direct command execution
command="$1"
arg1="${2:-}"
arg2="${3:-}"

case "$command" in
    "local")
        echo "Launching Local Docker Deployment..."
        "$DOCKER_SCRIPTS_DIR/deploy-local.sh" "$arg1" "$arg2"
        exit 0
        ;;
    "dockerhub")
        echo "Launching DockerHub Deployment..."
        "$DOCKER_SCRIPTS_DIR/deploy-dockerhub.sh" "$arg1" "$arg2"
        exit 0
        ;;
    "server")
        echo "Launching ATS Server Manager..."
        "$SCRIPT_DIR/scripts/ats_server_manager.bat"
        exit 0
        ;;
    "help")
        show_help
        exit 0
        ;;
    *)
        echo "Unknown command: $command"
        show_help
        exit 1
        ;;
esac

show_menu() {
    echo "Select deployment method:"
    echo ""
    echo "1. Local Development (Build images locally)"
    echo "2. Production (Pull from DockerHub)"
    echo "3. ATS Server Manager (Game server management)"
    echo "4. Help & Documentation"
    echo "5. Exit"
    echo ""
    read -p "Enter your choice (1-5): " choice
    
    case "$choice" in
        1) local_deployment ;;
        2) dockerhub_deployment ;;
        3) server_manager ;;
        4) show_help ;;
        5) exit 0 ;;
        *) 
            echo "Invalid choice. Please try again."
            show_menu
            ;;
    esac
}

local_deployment() {
    echo ""
    echo "================================================"
    echo "          Local Development Deployment"
    echo "================================================"
    echo ""
    echo "This will build Docker images locally and start services."
    echo "Perfect for development and testing."
    echo ""
    "$DOCKER_SCRIPTS_DIR/deploy-local.sh" start
}

dockerhub_deployment() {
    echo ""
    echo "================================================"
    echo "           Production Deployment"
    echo "================================================"
    echo ""
    echo "Choose deployment mode:"
    echo "1. Standard (Use local images if DockerHub fails)"
    echo "2. Production (Force DockerHub images)"
    echo "3. Specific Version"
    echo "4. Back to main menu"
    echo ""
    read -p "Enter your choice (1-4): " prod_choice
    
    case "$prod_choice" in
        1)
            "$DOCKER_SCRIPTS_DIR/deploy-dockerhub.sh" start
            ;;
        2)
            "$DOCKER_SCRIPTS_DIR/deploy-dockerhub.sh" start prod
            ;;
        3)
            read -p "Enter version tag (e.g., v1.2.3): " version
            "$DOCKER_SCRIPTS_DIR/deploy-dockerhub.sh" start prod "$version"
            ;;
        4)
            show_menu
            ;;
        *)
            echo "Invalid choice. Returning to main menu..."
            sleep 2
            show_menu
            ;;
    esac
}

server_manager() {
    echo ""
    echo "================================================"
    echo "           ATS Server Manager"
    echo "================================================"
    echo ""
    echo "Launching comprehensive ATS server management..."
    "$SCRIPT_DIR/scripts/ats_server_manager.bat"
}

show_help() {
    echo ""
    echo "================================================"
    echo "        ATS Server Management Help"
    echo "================================================"
    echo ""
    echo "COMMAND LINE USAGE:"
    echo "  $0 local [command]          - Local development deployment"
    echo "  $0 dockerhub [command]      - DockerHub production deployment"
    echo "  $0 server                   - ATS server management"
    echo ""
    echo "AVAILABLE COMMANDS:"
    echo "  start, stop, restart, logs, status, build, cleanup"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 local start              - Start local development"
    echo "  $0 dockerhub start prod     - Start production from DockerHub"
    echo "  $0 local logs ats-web       - Show web app logs"
    echo "  $0 dockerhub status         - Check service status"
    echo ""
    echo "DEPLOYMENT METHODS:"
    echo ""
    echo "1. LOCAL DEVELOPMENT:"
    echo "   - Builds Docker images from source code"
    echo "   - Uses docker-compose.yml"
    echo "   - Perfect for development and testing"
    echo "   - Faster iteration on code changes"
    echo ""
    echo "2. PRODUCTION (DOCKERHUB):"
    echo "   - Pulls pre-built images from DockerHub"
    echo "   - Uses docker-compose.prod.yml for production"
    echo "   - Faster deployment, smaller bandwidth usage"
    echo "   - Supports version tags for rollbacks"
    echo ""
    echo "3. ATS SERVER MANAGER:"
    echo "   - Comprehensive game server management"
    echo "   - Mod collection utilities"
    echo "   - Server configuration and monitoring"
    echo "   - Automated server operations"
    echo ""
    echo "REQUIREMENTS:"
    echo "  - Docker installed and running"
    echo "  - Docker Compose available"
    echo "  - Internet connection (for DockerHub deployment)"
    echo ""
    echo "DOCUMENTATION:"
    echo "  - Check docs/ folder for detailed guides"
    echo "  - README.md for quick start"
    echo "  - DOCKER_README.md for Docker-specific info"
    echo ""
    
    if [ $# -eq 0 ]; then
        read -p "Press any key to return to menu..." -n 1
        echo ""
        show_menu
    fi
}
