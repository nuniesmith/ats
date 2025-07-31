#!/bin/bash
# install-ssl-systemd.sh
# Install ATS SSL systemd service for automated certificate management
# Timer scheduled at 3:00 AM/PM to avoid conflicts with nginx (2:00) and FKS (2:30)

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SERVICE_NAME="ats-ssl-manager"
TIMER_NAME="ats-ssl-renewal"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        echo "Please run: sudo $0"
        exit 1
    fi
}

# Install SSL manager service
install_service() {
    log_info "Installing ATS SSL manager systemd service..."
    
    cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=ATS SSL Certificate Manager
Documentation=man:ssl-manager(8)
After=network-online.target
Wants=network-online.target
ConditionPathExists=${PROJECT_ROOT}/scripts/ssl-manager.sh

[Service]
Type=oneshot
User=root
Group=root
WorkingDirectory=${PROJECT_ROOT}
Environment=DOMAIN_NAME=ats.7gram.xyz
Environment=LETSENCRYPT_EMAIL=admin@7gram.xyz
EnvironmentFile=-/etc/default/ats-ssl-manager
ExecStart=${PROJECT_ROOT}/scripts/ssl-manager.sh renew
StandardOutput=journal
StandardError=journal
SyslogIdentifier=ats-ssl-manager

# Security hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=${PROJECT_ROOT}/ssl
ReadWritePaths=${PROJECT_ROOT}/config
ReadWritePaths=/var/log
ReadWritePaths=/tmp
ReadWritePaths=/var/lib/docker
PrivateTmp=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictRealtime=true
RestrictSUIDSGID=true
LockPersonality=true
MemoryDenyWriteExecute=false
RestrictNamespaces=~CLONE_NEWUSER

# Resource limits
CPUQuota=50%
MemoryLimit=512M
TasksMax=100

# Restart policy
Restart=on-failure
RestartSec=30
TimeoutStartSec=300
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
EOF
    
    log_success "✅ Service file created: /etc/systemd/system/${SERVICE_NAME}.service"
}

# Install SSL renewal timer
install_timer() {
    log_info "Installing ATS SSL renewal timer..."
    
    cat > "/etc/systemd/system/${TIMER_NAME}.timer" << EOF
[Unit]
Description=ATS SSL Certificate Renewal Timer
Documentation=man:ssl-manager(8)
Requires=${SERVICE_NAME}.service

[Timer]
# Run twice daily at 3:00 AM and 3:00 PM with randomization
# Offset from nginx (2:00) and FKS (2:30) to prevent conflicts
OnCalendar=*-*-* 03,15:00:00
RandomizedDelaySec=1800
Persistent=true
AccuracySec=1h

[Install]
WantedBy=timers.target
EOF
    
    log_success "✅ Timer file created: /etc/systemd/system/${TIMER_NAME}.timer"
}

# Create environment file
create_environment_file() {
    log_info "Creating environment configuration file..."
    
    cat > "/etc/default/${SERVICE_NAME}" << EOF
# ATS SSL Manager Environment Configuration
# Override default settings here

# Domain Configuration
DOMAIN_NAME=ats.7gram.xyz
LETSENCRYPT_EMAIL=admin@7gram.xyz

# Cloudflare DNS Challenge (optional)
# CLOUDFLARE_EMAIL=your-email@example.com
# CLOUDFLARE_API_TOKEN=your-api-token

# Logging
LOG_LEVEL=INFO

# Certificate settings
CERT_KEY_SIZE=4096
CERT_VALIDITY_DAYS=90

# Renewal settings
RENEWAL_THRESHOLD_DAYS=30
ENABLE_AUTO_RELOAD=true

# Notification settings (future use)
# NOTIFICATION_EMAIL=admin@7gram.xyz
# SLACK_WEBHOOK_URL=https://hooks.slack.com/...
EOF
    
    chmod 644 "/etc/default/${SERVICE_NAME}"
    log_success "✅ Environment file created: /etc/default/${SERVICE_NAME}"
}

# Create management script
create_management_script() {
    log_info "Creating SSL management helper script..."
    
    cat > "/usr/local/bin/ats-ssl" << 'EOF'
#!/bin/bash
# ATS SSL Management Helper Script

set -euo pipefail

SERVICE_NAME="ats-ssl-manager"
TIMER_NAME="ats-ssl-renewal"
PROJECT_ROOT="/home/jordan/oryx/code/repos/ats"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_status() {
    echo -e "${BLUE}🔒 ATS SSL Service Status${NC}"
    echo "Service: $SERVICE_NAME"
    echo "Timer: $TIMER_NAME"
    echo
    
    echo -e "${YELLOW}Systemd Service Status:${NC}"
    systemctl status "$SERVICE_NAME" --no-pager -l || true
    echo
    
    echo -e "${YELLOW}Timer Status:${NC}"
    systemctl status "$TIMER_NAME" --no-pager -l || true
    echo
    
    echo -e "${YELLOW}Timer Schedule:${NC}"
    systemctl list-timers "$TIMER_NAME" --no-pager || true
    echo
    
    echo -e "${YELLOW}Recent Service Logs:${NC}"
    journalctl -u "$SERVICE_NAME" --no-pager -n 10 || true
    echo
    
    if [ -f "$PROJECT_ROOT/scripts/ssl-manager.sh" ]; then
        echo -e "${YELLOW}Certificate Status:${NC}"
        "$PROJECT_ROOT/scripts/ssl-manager.sh" status || true
    fi
}

run_renewal() {
    echo -e "${BLUE}🔄 Running SSL certificate renewal...${NC}"
    systemctl start "$SERVICE_NAME"
    
    echo -e "${YELLOW}Service output:${NC}"
    journalctl -u "$SERVICE_NAME" --no-pager -f &
    local journal_pid=$!
    
    # Wait for service to complete
    while systemctl is-active --quiet "$SERVICE_NAME"; do
        sleep 1
    done
    
    # Stop following logs
    kill $journal_pid 2>/dev/null || true
    
    echo -e "${GREEN}✅ Renewal process completed${NC}"
}

start_service() {
    echo -e "${BLUE}🚀 Starting ATS SSL services...${NC}"
    systemctl start "$TIMER_NAME"
    systemctl enable "$TIMER_NAME"
    echo -e "${GREEN}✅ Timer started and enabled${NC}"
}

stop_service() {
    echo -e "${BLUE}🛑 Stopping ATS SSL services...${NC}"
    systemctl stop "$TIMER_NAME" || true
    systemctl disable "$TIMER_NAME" || true
    echo -e "${GREEN}✅ Timer stopped and disabled${NC}"
}

show_help() {
    cat << HELP
ATS SSL Management Helper

Usage: ats-ssl [COMMAND]

Commands:
    status      Show service and certificate status
    renew       Run certificate renewal now
    start       Start and enable the renewal timer
    stop        Stop and disable the renewal timer
    restart     Restart the renewal timer
    logs        Show recent service logs
    help        Show this help message

Examples:
    ats-ssl status          # Check overall status
    ats-ssl renew           # Force renewal now
    ats-ssl start           # Enable automatic renewals
HELP
}

case "${1:-status}" in
    status)
        show_status
        ;;
    renew)
        run_renewal
        ;;
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        stop_service
        sleep 2
        start_service
        ;;
    logs)
        echo -e "${YELLOW}Recent SSL Manager Logs:${NC}"
        journalctl -u "$SERVICE_NAME" --no-pager -n 50 || true
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
EOF
    
    chmod +x "/usr/local/bin/ats-ssl"
    log_success "✅ Management script created: /usr/local/bin/ats-ssl"
}

# Setup systemd services
setup_systemd() {
    log_info "Setting up systemd services..."
    
    # Reload systemd daemon
    systemctl daemon-reload
    
    # Enable but don't start the timer yet (let user choose)
    systemctl enable "${TIMER_NAME}.timer"
    
    log_success "✅ Systemd services configured"
    log_info "Use 'ats-ssl start' to begin automatic renewals"
}

# Test installation
test_installation() {
    log_info "Testing SSL manager installation..."
    
    # Test SSL manager script
    if [ -f "${PROJECT_ROOT}/scripts/ssl-manager.sh" ]; then
        if "${PROJECT_ROOT}/scripts/ssl-manager.sh" help >/dev/null 2>&1; then
            log_success "✅ SSL manager script is working"
        else
            log_warn "⚠️  SSL manager script may have issues"
        fi
    else
        log_error "❌ SSL manager script not found"
        return 1
    fi
    
    # Test systemd files
    if systemctl list-unit-files "${SERVICE_NAME}.service" >/dev/null 2>&1; then
        log_success "✅ Service file is valid"
    else
        log_error "❌ Service file validation failed"
        return 1
    fi
    
    if systemctl list-unit-files "${TIMER_NAME}.timer" >/dev/null 2>&1; then
        log_success "✅ Timer file is valid"
    else
        log_error "❌ Timer file validation failed"
        return 1
    fi
    
    # Test management script
    if command -v ats-ssl >/dev/null 2>&1; then
        log_success "✅ Management script is available"
    else
        log_error "❌ Management script not in PATH"
        return 1
    fi
    
    log_success "🎉 Installation test completed successfully"
}

# Main installation process
main() {
    echo -e "${BLUE}🔧 Installing ATS SSL Systemd Services${NC}"
    echo "Project: $PROJECT_ROOT"
    echo "Service: $SERVICE_NAME"
    echo "Timer: $TIMER_NAME"
    echo
    
    check_root
    
    # Make ssl-manager.sh executable
    chmod +x "${PROJECT_ROOT}/scripts/ssl-manager.sh"
    
    install_service
    install_timer
    create_environment_file
    create_management_script
    setup_systemd
    test_installation
    
    echo
    log_success "🎉 ATS SSL systemd services installed successfully!"
    echo
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Configure environment: sudo nano /etc/default/${SERVICE_NAME}"
    echo "2. Start automatic renewals: sudo ats-ssl start"
    echo "3. Check status: ats-ssl status"
    echo "4. Test renewal: sudo ats-ssl renew"
    echo
    echo -e "${YELLOW}Timer schedule:${NC} Twice daily at 3:00 AM/PM (randomized ±30min)"
    echo -e "${YELLOW}Logs location:${NC} journalctl -u ${SERVICE_NAME}"
    echo -e "${YELLOW}Management tool:${NC} ats-ssl"
}

# Execute main function
main "$@"
