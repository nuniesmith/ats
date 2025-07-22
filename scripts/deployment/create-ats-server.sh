#!/bin/bash

# American Truck Simulator Dedicated Server - Linode Server Creation Script
# Creates a Linode server optimized for running ATS dedicated server

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

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Default values
SERVER_NAME="ats-server"
SERVER_TYPE="g6-standard-1"  # $12/month - 2GB RAM, 1 CPU
SERVER_REGION="ca-central"   # Toronto, Canada
SERVER_IMAGE="linode/ubuntu24.04"
FORCE_NEW=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            SERVER_NAME="$2"
            shift 2
            ;;
        --type)
            SERVER_TYPE="$2"
            shift 2
            ;;
        --region)
            SERVER_REGION="$2"
            shift 2
            ;;
        --force-new)
            FORCE_NEW=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --name <name>       Server name (default: ats-server)"
            echo "  --type <type>       Linode instance type (default: g6-standard-2)"
            echo "  --region <region>   Linode region (default: us-central)"
            echo "  --force-new         Force creation of new server"
            echo "  --help              Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
done

log "Starting ATS Dedicated Server creation on Linode"

# Validate required environment variables
if [ -z "$LINODE_CLI_TOKEN" ]; then
    error "LINODE_CLI_TOKEN environment variable is required"
    exit 1
fi

if [ -z "$ROOT_PASSWORD" ]; then
    error "ROOT_PASSWORD environment variable is required"
    exit 1
fi

# Configure Linode CLI
export LINODE_CLI_TOKEN="$LINODE_CLI_TOKEN"

# Check for existing server
log "Checking for existing ATS servers..."

# Check if jq is available
if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found - using alternative parsing method"
    # Try to find existing server using grep/sed
    EXISTING_SERVER=$(linode-cli linodes list --text | grep "$SERVER_NAME" | awk '{print $1}' | head -1)
    if [ -n "$EXISTING_SERVER" ] && [ "$FORCE_NEW" != "true" ]; then
        log "Found existing server ID: $EXISTING_SERVER"
        SERVER_ID="$EXISTING_SERVER"
        # Get IP using text output - look for the IP address column
        SERVER_INFO=$(linode-cli linodes view "$SERVER_ID" --text 2>/dev/null)
        log "Debug: Server info output:"
        echo "$SERVER_INFO" | head -10
        # Try different patterns to extract IP
        SERVER_IP=$(echo "$SERVER_INFO" | grep -E '^ipv4' | awk '{print $2}' | head -1)
        if [ -z "$SERVER_IP" ]; then
            # Try alternative pattern
            SERVER_IP=$(echo "$SERVER_INFO" | awk '/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {print $1; exit}')
        fi
        if [ -z "$SERVER_IP" ]; then
            # Try yet another pattern - look for IP in the output
            SERVER_IP=$(echo "$SERVER_INFO" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        fi
        log "Extracted IP: $SERVER_IP"
    fi
else
    # Use jq if available
    EXISTING_SERVER=$(linode-cli linodes list --json | jq -r ".[] | select(.label == \"$SERVER_NAME\") | .id" | head -1)
    if [ -n "$EXISTING_SERVER" ] && [ "$FORCE_NEW" != "true" ]; then
        log "Found existing server: $EXISTING_SERVER"
        SERVER_ID="$EXISTING_SERVER"
        SERVER_JSON=$(linode-cli linodes view "$SERVER_ID" --json 2>/dev/null)
        log "Debug: Server JSON response (first 500 chars):"
        echo "$SERVER_JSON" | head -c 500
        SERVER_IP=$(echo "$SERVER_JSON" | jq -r '.[0].ipv4[0]' 2>/dev/null)
        # If that fails, try alternative jq patterns
        if [ -z "$SERVER_IP" ] || [ "$SERVER_IP" = "null" ]; then
            SERVER_IP=$(echo "$SERVER_JSON" | jq -r '.ipv4[0]' 2>/dev/null)
        fi
        if [ -z "$SERVER_IP" ] || [ "$SERVER_IP" = "null" ]; then
            SERVER_IP=$(echo "$SERVER_JSON" | jq -r '.[0].ipv4_address' 2>/dev/null)
        fi
        log "Extracted IP with jq: $SERVER_IP"
    fi
fi

if [ -n "$EXISTING_SERVER" ] && [ "$FORCE_NEW" != "true" ]; then
    log "Using existing server: ID=$SERVER_ID, IP=$SERVER_IP"
    
    # Fallback: If we still don't have an IP but we know the server exists
    if [ -z "$SERVER_IP" ] || [ "$SERVER_IP" = "null" ]; then
        warn "Failed to extract IP from Linode API"
        # Known server IPs fallback
        if [ "$SERVER_ID" = "80547543" ]; then
            SERVER_IP="172.105.18.248"
            log "Using known IP for server $SERVER_ID: $SERVER_IP"
        else
            error "Could not determine IP for server $SERVER_ID"
            exit 1
        fi
    fi
else
    if [ -n "$EXISTING_SERVER" ]; then
        log "Deleting existing server..."
        linode-cli linodes delete "$EXISTING_SERVER" --skip-checks
        sleep 10
    fi
    
    log "Creating new Linode server..."
    log "  Name: $SERVER_NAME"
    log "  Type: $SERVER_TYPE"
    log "  Region: $SERVER_REGION"
    log "  Image: $SERVER_IMAGE"
    
    # Create the server
    RESULT=$(linode-cli linodes create \
        --label "$SERVER_NAME" \
        --type "$SERVER_TYPE" \
        --region "$SERVER_REGION" \
        --image "$SERVER_IMAGE" \
        --root_pass "$ROOT_PASSWORD" \
        --json)
    
    SERVER_ID=$(echo "$RESULT" | jq -r '.[0].id')
    SERVER_IP=$(echo "$RESULT" | jq -r '.[0].ipv4[0]')
    
    log "Server created: ID=$SERVER_ID, IP=$SERVER_IP"
    
    # Wait for server to be ready
    log "Waiting for server to boot..."
    while true; do
        STATUS=$(linode-cli linodes view "$SERVER_ID" --json | jq -r '.[0].status')
        if [ "$STATUS" = "running" ]; then
            break
        fi
        sleep 5
    done
    
    log "Server is running, waiting for SSH..."
    sleep 30
fi

# Create output file
cat > server-details.env << EOF
# ATS Server Details
SERVER_ID=$SERVER_ID
SERVER_IP=$SERVER_IP
SERVER_NAME=$SERVER_NAME
SERVER_TYPE=$SERVER_TYPE
SERVER_REGION=$SERVER_REGION
SERVER_IMAGE=$SERVER_IMAGE
IS_NEW_SERVER=$([[ -n "$EXISTING_SERVER" ]] && echo "false" || echo "true")
CREATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TARGET_HOST=$SERVER_IP
EOF

log "Server ready!"
log "  ID: $SERVER_ID"
log "  IP: $SERVER_IP"

# Debug output
log "Debug: Writing server-details.env with:"
log "  SERVER_IP=$SERVER_IP"
log "  SERVER_ID=$SERVER_ID"
log "  IS_NEW_SERVER=$([[ -n "$EXISTING_SERVER" ]] && echo "false" || echo "true")"

log ""
log "Next steps:"
log "1. SSH to server: ssh root@$SERVER_IP"
log "2. Run server setup script"
log "3. Configure ATS dedicated server"
