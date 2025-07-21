#!/bin/bash

# American Truck Simulator Dedicated Server Startup Script
# This script starts the ATS dedicated server with proper configuration

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Server directories
SERVER_DIR="/home/ats-server"
LOG_DIR="$SERVER_DIR/logs"
CONFIG_DIR="$SERVER_DIR/config"

# Create necessary directories
mkdir -p "$LOG_DIR"
mkdir -p "$CONFIG_DIR"

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# Check if server executable exists
if [ ! -f "$SERVER_DIR/bin/linux_x64/amtrucks_server" ]; then
    error "ATS server executable not found at $SERVER_DIR/bin/linux_x64/amtrucks_server"
    error "Please ensure the server is properly installed using SteamCMD"
    exit 1
fi

# Check for required configuration files
if [ ! -f "$SERVER_DIR/server_config.sii" ]; then
    warn "server_config.sii not found, creating default configuration..."
    cp "$CONFIG_DIR/server_config.sii.default" "$SERVER_DIR/server_config.sii" 2>/dev/null || {
        error "Failed to create server_config.sii"
        exit 1
    }
fi

if [ ! -f "$SERVER_DIR/server_packages.sii" ] || [ ! -f "$SERVER_DIR/server_packages.dat" ]; then
    error "server_packages files not found!"
    error "You must generate these files from the game client using the export_server_packages command"
    exit 1
fi

# Set up Steam library path for Linux
export LD_LIBRARY_PATH="$SERVER_DIR/linux64:$LD_LIBRARY_PATH"

# Create steamclient.so link if it doesn't exist
if [ ! -f "$HOME/.steam/sdk64/steamclient.so" ]; then
    log "Creating Steam client library link..."
    mkdir -p "$HOME/.steam/sdk64"
    if [ -f "/usr/lib/steam/steamclient.so" ]; then
        ln -sf "/usr/lib/steam/steamclient.so" "$HOME/.steam/sdk64/steamclient.so"
    elif [ -f "$SERVER_DIR/linux64/steamclient.so" ]; then
        ln -sf "$SERVER_DIR/linux64/steamclient.so" "$HOME/.steam/sdk64/steamclient.so"
    else
        error "steamclient.so not found!"
        exit 1
    fi
fi

# Function to stop the server gracefully
stop_server() {
    log "Stopping ATS dedicated server..."
    if [ -n "$SERVER_PID" ]; then
        kill -SIGTERM "$SERVER_PID" 2>/dev/null
        wait "$SERVER_PID" 2>/dev/null
    fi
    log "Server stopped"
    exit 0
}

# Set up signal handlers
trap stop_server SIGTERM SIGINT

# Start the server
log "Starting American Truck Simulator Dedicated Server..."
log "Server directory: $SERVER_DIR"
log "Log directory: $LOG_DIR"

# Change to server directory
cd "$SERVER_DIR" || exit 1

# Start the server with parameters
./bin/linux_x64/amtrucks_server \
    -server "$SERVER_DIR/server_packages.sii" \
    -server_cfg "$SERVER_DIR/server_config.sii" \
    -homedir "$SERVER_DIR" \
    -nosingle \
    >> "$LOG_DIR/server.log" 2>&1 &

SERVER_PID=$!

log "Server started with PID: $SERVER_PID"
log "Server logs: $LOG_DIR/server.log"

# Monitor server process
while true; do
    if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        error "Server process terminated unexpectedly"
        exit 1
    fi
    sleep 10
done
