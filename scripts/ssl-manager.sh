#!/bin/bash
# ssl-manager.sh
# SSL Certificate Management for ATS Game Server Web Interface
# Unified SSL management with self-signed fallback and Let's Encrypt automation

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SSL_DIR="$PROJECT_ROOT/ssl"
LETSENCRYPT_DIR="$PROJECT_ROOT/ssl/letsencrypt"
SELF_SIGNED_DIR="$PROJECT_ROOT/ssl/self-signed"
LOG_FILE="/var/log/ats-ssl-manager.log"
DOMAIN_NAME="${DOMAIN_NAME:-ats.7gram.xyz}"
EMAIL="${LETSENCRYPT_EMAIL:-admin@7gram.xyz}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
log_success() { log "SUCCESS" "$@"; }

# Create directory structure
setup_directories() {
    log_info "📁 Setting up SSL directory structure..."
    mkdir -p "$SSL_DIR" "$LETSENCRYPT_DIR" "$SELF_SIGNED_DIR"
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
}

# Generate Diffie-Hellman parameters
generate_dhparam() {
    local dhparam_file="$SSL_DIR/dhparam.pem"
    
    if [ ! -f "$dhparam_file" ]; then
        log_info "🔐 Generating Diffie-Hellman parameters (this may take a while)..."
        openssl dhparam -out "$dhparam_file" 2048
        chmod 644 "$dhparam_file"
        log_success "✅ DH parameters generated"
    else
        log_info "✅ DH parameters already exist"
    fi
}

# Generate self-signed certificates for ATS
generate_self_signed() {
    local domain="$DOMAIN_NAME"
    local cert_dir="$SELF_SIGNED_DIR"
    
    log_info "� Generating self-signed certificate for ATS: $domain..."
    
    # Generate DH parameters first
    generate_dhparam
    
    # Create certificate configuration
    cat > "$cert_dir/openssl.cnf" << EOF
[req]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C=CA
ST=Ontario
L=Toronto
O=ATS Game Server
OU=Gaming Department
CN=$domain

[v3_req]
basicConstraints = CA:FALSE
keyUsage = keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $domain
DNS.2 = *.ats.7gram.xyz
DNS.3 = localhost
IP.1 = 127.0.0.1
EOF

    # Generate private key
    openssl genrsa -out "$cert_dir/$domain.key" 4096
    
    # Generate certificate
    openssl req -new -x509 -key "$cert_dir/$domain.key" \
        -out "$cert_dir/$domain.crt" \
        -days 365 \
        -config "$cert_dir/openssl.cnf" \
        -extensions v3_req
    
    # Set proper permissions
    chmod 600 "$cert_dir/$domain.key"
    chmod 644 "$cert_dir/$domain.crt"
    
    log_success "✅ Self-signed certificate generated for ATS"
    return 0
}

# Check if domain is accessible from internet
check_domain_accessibility() {
    local domain="$1"
    
    log_info "🌐 Checking if $domain is accessible from internet..."
    
    # Try to resolve domain
    if ! dig +short "$domain" >/dev/null 2>&1; then
        log_warn "⚠️  Domain $domain does not resolve"
        return 1
    fi
    
    # Check if port 80 is accessible (required for HTTP-01 challenge)
    if ! timeout 10 bash -c "echo >/dev/tcp/$(dig +short "$domain")/80" 2>/dev/null; then
        log_warn "⚠️  Port 80 is not accessible on $domain"
        return 1
    fi
    
    log_success "✅ Domain $domain is accessible"
    return 0
}

# Generate Let's Encrypt certificate using HTTP-01 challenge
generate_letsencrypt_http() {
    local domain="$DOMAIN_NAME"
    local webroot="/var/www/certbot"
    
    log_info "� Generating Let's Encrypt certificate for $domain using HTTP-01..."
    
    # Ensure webroot directory exists
    mkdir -p "$webroot"
    
    # Run certbot with HTTP-01 challenge
    if docker run --rm \
        -v "$LETSENCRYPT_DIR:/etc/letsencrypt" \
        -v "$webroot:/var/www/certbot" \
        -v "$PROJECT_ROOT/config/certbot:/etc/letsencrypt/config" \
        certbot/certbot:latest \
        certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email "$EMAIL" \
        --agree-tos \
        --no-eff-email \
        --force-renewal \
        -d "$domain" 2>&1 | tee -a "$LOG_FILE"; then
        
        log_success "✅ Let's Encrypt certificate generated successfully"
        return 0
    else
        log_error "❌ Failed to generate Let's Encrypt certificate"
        return 1
    fi
}

# Generate Let's Encrypt certificate using DNS-01 challenge (Cloudflare)
generate_letsencrypt_dns() {
    local domain="$DOMAIN_NAME"
    
    log_info "🔐 Generating Let's Encrypt certificate for $domain using DNS-01..."
    
    # Check for Cloudflare credentials
    if [ -z "${CLOUDFLARE_EMAIL:-}" ] || [ -z "${CLOUDFLARE_API_TOKEN:-}" ]; then
        log_error "❌ Cloudflare credentials not found"
        return 1
    fi
    
    # Create Cloudflare credentials file
    mkdir -p "$PROJECT_ROOT/config/certbot"
    cat > "$PROJECT_ROOT/config/certbot/cloudflare.ini" << EOF
dns_cloudflare_email = $CLOUDFLARE_EMAIL
dns_cloudflare_api_token = $CLOUDFLARE_API_TOKEN
EOF
    chmod 600 "$PROJECT_ROOT/config/certbot/cloudflare.ini"
    
    # Run certbot with DNS-01 challenge
    if docker run --rm \
        -v "$LETSENCRYPT_DIR:/etc/letsencrypt" \
        -v "$PROJECT_ROOT/config/certbot:/etc/letsencrypt/config" \
        certbot/dns-cloudflare:latest \
        certonly \
        --dns-cloudflare \
        --dns-cloudflare-credentials /etc/letsencrypt/config/cloudflare.ini \
        --email "$EMAIL" \
        --agree-tos \
        --no-eff-email \
        --force-renewal \
        -d "$domain" 2>&1 | tee -a "$LOG_FILE"; then
        
        log_success "✅ Let's Encrypt certificate generated successfully"
        return 0
    else
        log_error "❌ Failed to generate Let's Encrypt certificate"
        return 1
    fi
}

# Link active certificate
link_certificate() {
    local source_dir="$1"
    local domain="$DOMAIN_NAME"
    
    log_info "🔗 Linking active certificate..."
    
    # Create active certificate links
    if [ -f "$source_dir/$domain.crt" ] && [ -f "$source_dir/$domain.key" ]; then
        ln -sf "$source_dir/$domain.crt" "$SSL_DIR/server.crt"
        ln -sf "$source_dir/$domain.key" "$SSL_DIR/server.key"
        
        # Create domain-specific links for nginx
        ln -sf "$source_dir/$domain.crt" "$SSL_DIR/$domain.crt"
        ln -sf "$source_dir/$domain.key" "$SSL_DIR/$domain.key"
        
        log_success "✅ Certificate linked successfully"
        return 0
    else
        log_error "❌ Certificate files not found in $source_dir"
        return 1
    fi
}

# Link Let's Encrypt certificate
link_letsencrypt() {
    local domain="$DOMAIN_NAME"
    local le_live="$LETSENCRYPT_DIR/live/$domain"
    
    if [ -f "$le_live/fullchain.pem" ] && [ -f "$le_live/privkey.pem" ]; then
        ln -sf "$le_live/fullchain.pem" "$SSL_DIR/server.crt"
        ln -sf "$le_live/privkey.pem" "$SSL_DIR/server.key"
        ln -sf "$le_live/fullchain.pem" "$SSL_DIR/$domain.crt"
        ln -sf "$le_live/privkey.pem" "$SSL_DIR/$domain.key"
        
        log_success "✅ Let's Encrypt certificate linked successfully"
        return 0
    else
        log_error "❌ Let's Encrypt certificate files not found"
        return 1
    fi
}

# Reload nginx (if using web interface)
reload_nginx() {
    log_info "🔄 Reloading ATS web nginx..."
    
    # Check if nginx container exists and is running
    if docker-compose -f "$PROJECT_ROOT/docker-compose.yml" ps ats-web 2>/dev/null | grep -q "Up"; then
        if docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec ats-web nginx -t 2>/dev/null; then
            if docker-compose -f "$PROJECT_ROOT/docker-compose.yml" exec ats-web nginx -s reload 2>/dev/null; then
                log_success "✅ Nginx reloaded successfully"
                return 0
            else
                log_error "❌ Failed to reload nginx"
                return 1
            fi
        else
            log_error "❌ Nginx configuration test failed"
            return 1
        fi
    else
        log_info "ℹ️  ATS web service not running, skipping nginx reload"
        return 0
    fi
}

# Check certificate expiry
check_certificate_expiry() {
    local cert_file="$1"
    local days_threshold="${2:-30}"
    
    if [ ! -f "$cert_file" ]; then
        return 1
    fi
    
    local expiry_date=$(openssl x509 -enddate -noout -in "$cert_file" | cut -d= -f2)
    local expiry_epoch=$(date -d "$expiry_date" +%s)
    local current_epoch=$(date +%s)
    local days_until_expiry=$(( (expiry_epoch - current_epoch) / 86400 ))
    
    log_info "� Certificate expires in $days_until_expiry days"
    
    if [ "$days_until_expiry" -lt "$days_threshold" ]; then
        log_warn "⚠️  Certificate expires in less than $days_threshold days"
        return 1
    fi
    
    return 0
}

# Renew Let's Encrypt certificate
renew_letsencrypt() {
    log_info "🔄 Renewing Let's Encrypt certificates..."
    
    if docker run --rm \
        -v "$LETSENCRYPT_DIR:/etc/letsencrypt" \
        -v "/var/www/certbot:/var/www/certbot" \
        certbot/certbot:latest \
        renew --webroot --webroot-path=/var/www/certbot --quiet 2>&1 | tee -a "$LOG_FILE"; then
        
        log_success "✅ Certificate renewal completed"
        return 0
    else
        log_error "❌ Certificate renewal failed"
        return 1
    fi
}

# Main certificate management function
manage_certificate() {
    local domain="$DOMAIN_NAME"
    
    log_info "� Starting SSL certificate management for ATS: $domain"
    
    setup_directories
    
    # Always generate self-signed as fallback
    generate_self_signed
    link_certificate "$SELF_SIGNED_DIR"
    
    # Try to get Let's Encrypt certificate
    local letsencrypt_success=false
    
    if check_domain_accessibility "$domain"; then
        # Try HTTP-01 challenge first
        if generate_letsencrypt_http; then
            link_letsencrypt
            letsencrypt_success=true
        # Fallback to DNS-01 if HTTP-01 fails and credentials are available
        elif [ -n "${CLOUDFLARE_EMAIL:-}" ] && [ -n "${CLOUDFLARE_API_TOKEN:-}" ]; then
            log_info "🔄 Falling back to DNS-01 challenge..."
            if generate_letsencrypt_dns; then
                link_letsencrypt
                letsencrypt_success=true
            fi
        fi
    else
        # Domain not accessible, try DNS-01 if credentials available
        if [ -n "${CLOUDFLARE_EMAIL:-}" ] && [ -n "${CLOUDFLARE_API_TOKEN:-}" ]; then
            log_info "🔄 Domain not accessible, trying DNS-01 challenge..."
            if generate_letsencrypt_dns; then
                link_letsencrypt
                letsencrypt_success=true
            fi
        fi
    fi
    
    if [ "$letsencrypt_success" = true ]; then
        log_success "🎉 Using Let's Encrypt certificate"
        echo "letsencrypt" > "$SSL_DIR/cert_type"
    else
        log_warn "⚠️  Using self-signed certificate as fallback"
        echo "self-signed" > "$SSL_DIR/cert_type"
    fi
    
    # Reload nginx if it's running
    reload_nginx
    
    log_success "✅ SSL certificate management completed for ATS"
}

# Renewal function for cron/systemd
renew_certificates() {
    local domain="$DOMAIN_NAME"
    
    log_info "🔄 Starting certificate renewal check for ATS..."
    
    # Check if we have a Let's Encrypt certificate
    if [ -f "$SSL_DIR/cert_type" ] && [ "$(cat "$SSL_DIR/cert_type")" = "letsencrypt" ]; then
        local cert_file="$SSL_DIR/server.crt"
        
        if check_certificate_expiry "$cert_file" 30; then
            log_info "✅ Certificate is still valid, no renewal needed"
            return 0
        fi
        
        log_info "🔄 Certificate needs renewal, attempting renewal..."
        if renew_letsencrypt; then
            reload_nginx
            log_success "✅ Certificate renewed successfully"
        else
            log_error "❌ Certificate renewal failed, keeping existing certificate"
        fi
    else
        log_info "ℹ️  Using self-signed certificate, checking if Let's Encrypt is now possible..."
        manage_certificate
    fi
}

# Certificate status
show_status() {
    echo -e "${BLUE}📋 ATS SSL Certificate Status${NC}"
    echo "Domain: $DOMAIN_NAME"
    
    if [ -f "$SSL_DIR/cert_type" ]; then
        local cert_type=$(cat "$SSL_DIR/cert_type")
        echo "Certificate Type: $cert_type"
    fi
    
    if [ -f "$SSL_DIR/server.crt" ]; then
        echo -e "\n${GREEN}Active Certificate Details:${NC}"
        openssl x509 -in "$SSL_DIR/server.crt" -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After :|DNS:)"
        
        local expiry_date=$(openssl x509 -enddate -noout -in "$SSL_DIR/server.crt" | cut -d= -f2)
        local expiry_epoch=$(date -d "$expiry_date" +%s)
        local current_epoch=$(date +%s)
        local days_until_expiry=$(( (expiry_epoch - current_epoch) / 86400 ))
        
        echo -e "\n${YELLOW}Expiry: $expiry_date ($days_until_expiry days remaining)${NC}"
    else
        echo -e "${RED}❌ No active certificate found${NC}"
    fi
}

# Help function
show_help() {
    cat << EOF
ATS SSL Certificate Manager

Usage: $0 [COMMAND]

Commands:
    setup       Initial SSL certificate setup (default)
    renew       Renew existing certificates
    self-signed Generate only self-signed certificate
    letsencrypt Generate only Let's Encrypt certificate
    status      Show certificate status
    help        Show this help message

Environment Variables:
    DOMAIN_NAME          Domain name for certificate (default: ats.7gram.xyz)
    LETSENCRYPT_EMAIL    Email for Let's Encrypt registration
    CLOUDFLARE_EMAIL     Cloudflare account email (for DNS challenge)
    CLOUDFLARE_API_TOKEN Cloudflare API token (for DNS challenge)

Examples:
    $0 setup                    # Initial setup with fallback
    $0 renew                    # Renew certificates
    DOMAIN_NAME=ats.example.com $0 setup
EOF
}

# Main execution
main() {
    local command="${1:-setup}"
    
    case "$command" in
        setup)
            manage_certificate
            ;;
        renew)
            renew_certificates
            ;;
        self-signed)
            setup_directories
            generate_self_signed
            link_certificate "$SELF_SIGNED_DIR"
            echo "self-signed" > "$SSL_DIR/cert_type"
            ;;
        letsencrypt)
            setup_directories
            if generate_letsencrypt_http || generate_letsencrypt_dns; then
                link_letsencrypt
                echo "letsencrypt" > "$SSL_DIR/cert_type"
            fi
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
