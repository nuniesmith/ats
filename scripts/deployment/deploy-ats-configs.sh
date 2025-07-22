#!/bin/bash

# Deploy ATS Server Configuration Files
# This script copies server_packages files from the repository to the remote server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Parse arguments
SERVER_IP="$1"
if [ -z "$SERVER_IP" ]; then
    error "Server IP is required"
    echo "Usage: $0 <server-ip>"
    exit 1
fi

log "Deploying ATS configuration files to $SERVER_IP"

# Check if files exist
if [ ! -f "config/server_packages.dat" ]; then
    error "config/server_packages.dat not found!"
    exit 1
fi

if [ ! -f "config/server_packages.sii" ]; then
    error "config/server_packages.sii not found!"
    exit 1
fi

if [ ! -f "config/server_config.sii" ]; then
    error "config/server_config.sii not found!"
    exit 1
fi

log "Found all required configuration files"

# Check if sshpass is needed and available
if [ -n "$SSHPASS" ]; then
    if ! command -v sshpass >/dev/null 2>&1; then
        error "sshpass is required but not installed"
        echo "Please install sshpass or use SSH key authentication"
        exit 1
    fi
fi

# Copy files to server
log "Copying server packages to remote server..."
if [ -n "$SSHPASS" ]; then
    # Use sshpass if password is provided
    sshpass -p "$SSHPASS" scp -o StrictHostKeyChecking=no \
        config/server_packages.dat \
        config/server_packages.sii \
        config/server_config.sii \
        root@$SERVER_IP:/home/ats-server/
else
    # Use SSH key authentication
    scp -o StrictHostKeyChecking=no \
        config/server_packages.dat \
        config/server_packages.sii \
        config/server_config.sii \
        root@$SERVER_IP:/home/ats-server/
fi

# Copy startup scripts
log "Copying startup scripts..."
if [ -n "$SSHPASS" ]; then
    sshpass -p "$SSHPASS" scp -o StrictHostKeyChecking=no \
        scripts/start_ats_server.sh \
        root@$SERVER_IP:/home/ats-server/
else
    scp -o StrictHostKeyChecking=no \
        scripts/start_ats_server.sh \
        root@$SERVER_IP:/home/ats-server/
fi

# Make scripts executable on remote
if [ -n "$SSHPASS" ]; then
    sshpass -p "$SSHPASS" ssh -o StrictHostKeyChecking=no root@$SERVER_IP "chmod +x /home/ats-server/*.sh"
else
    ssh -o StrictHostKeyChecking=no root@$SERVER_IP "chmod +x /home/ats-server/*.sh"
fi

log "✅ Configuration files deployed successfully!"
log ""
log "Files deployed:"
log "  - server_packages.dat"
log "  - server_packages.sii"
log "  - server_config.sii"
log "  - start_ats_server.sh"
