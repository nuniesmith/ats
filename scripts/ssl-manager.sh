#!/bin/bash
# SSL Certificate Management Script for ATS
# Handles self-signed certificates and Let's Encrypt lifecycle

set -e

DOMAIN_NAME="${DOMAIN_NAME:-ats.7gram.xyz}"
CERT_DIR="/etc/ssl/ats"
LETSENCRYPT_DIR="/etc/letsencrypt/live/$DOMAIN_NAME"

echo "🔒 ATS SSL Certificate Manager"
echo "Domain: $DOMAIN_NAME"

# Create certificate directories
mkdir -p "$CERT_DIR"
mkdir -p /etc/letsencrypt/live

# Function to generate self-signed certificates
generate_self_signed() {
    echo "🔧 Generating self-signed SSL certificates..."
    
    # Create self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$CERT_DIR/privkey.pem" \
        -out "$CERT_DIR/fullchain.pem" \
        -subj "/C=US/ST=State/L=City/O=ATS/OU=IT/CN=$DOMAIN_NAME/emailAddress=admin@$DOMAIN_NAME" \
        -addext "subjectAltName=DNS:$DOMAIN_NAME,DNS:www.$DOMAIN_NAME,DNS:api.$DOMAIN_NAME"
    
    # Create symlinks to Let's Encrypt expected locations
    mkdir -p "$LETSENCRYPT_DIR"
    ln -sf "$CERT_DIR/fullchain.pem" "$LETSENCRYPT_DIR/fullchain.pem"
    ln -sf "$CERT_DIR/privkey.pem" "$LETSENCRYPT_DIR/privkey.pem"
    
    echo "✅ Self-signed certificates generated and linked"
    echo "   Certificate: $LETSENCRYPT_DIR/fullchain.pem"
    echo "   Private Key: $LETSENCRYPT_DIR/privkey.pem"
}

# Function to request Let's Encrypt certificates
request_letsencrypt() {
    echo "🔒 Requesting Let's Encrypt certificates..."
    
    # Check if Cloudflare credentials exist
    if [[ -f /root/.secrets/cloudflare.ini ]]; then
        echo "📋 Using Cloudflare DNS challenge..."
        
        # Install certbot cloudflare plugin if not present
        if ! command -v certbot >/dev/null 2>&1; then
            echo "📦 Installing certbot..."
            pacman -S --noconfirm certbot || pip install certbot
        fi
        
        if ! pip list | grep -q certbot-dns-cloudflare; then
            echo "📦 Installing Cloudflare DNS plugin..."
            pip install certbot-dns-cloudflare
        fi
        
        # Request certificates
        certbot certonly \
            --dns-cloudflare \
            --dns-cloudflare-credentials /root/.secrets/cloudflare.ini \
            --dns-cloudflare-propagation-seconds 60 \
            --email admin@7gram.xyz \
            --agree-tos \
            --non-interactive \
            --expand \
            -d "$DOMAIN_NAME" \
            -d "www.$DOMAIN_NAME" \
            -d "api.$DOMAIN_NAME" || {
            echo "❌ Let's Encrypt certificate request failed"
            return 1
        }
        
        if [[ -f "$LETSENCRYPT_DIR/fullchain.pem" ]]; then
            echo "✅ Let's Encrypt certificates obtained successfully"
            # Remove self-signed certificate symlinks
            rm -f "$CERT_DIR/fullchain.pem" "$CERT_DIR/privkey.pem" 2>/dev/null || true
            return 0
        else
            echo "❌ Let's Encrypt certificates not found after request"
            return 1
        fi
    else
        echo "⚠️ Cloudflare credentials not found, cannot request Let's Encrypt certificates"
        echo "   Please configure /root/.secrets/cloudflare.ini"
        return 1
    fi
}

# Function to check certificate validity
check_certificates() {
    if [[ -f "$LETSENCRYPT_DIR/fullchain.pem" ]]; then
        local expiry_date=$(openssl x509 -in "$LETSENCRYPT_DIR/fullchain.pem" -noout -enddate | cut -d= -f2)
        local expiry_epoch=$(date -d "$expiry_date" +%s)
        local current_epoch=$(date +%s)
        local days_until_expiry=$(( (expiry_epoch - current_epoch) / 86400 ))
        
        echo "📋 Certificate expires: $expiry_date ($days_until_expiry days)"
        
        if [[ $days_until_expiry -lt 30 ]]; then
            echo "⚠️ Certificate expires in less than 30 days - renewal needed"
            return 1
        else
            echo "✅ Certificate is valid"
            return 0
        fi
    else
        echo "❌ No certificates found"
        return 1
    fi
}

# Function to restart nginx
restart_nginx() {
    echo "🔄 Restarting nginx..."
    if command -v docker-compose >/dev/null 2>&1 && [[ -f /opt/ats/docker-compose.yml ]]; then
        cd /opt/ats
        docker-compose restart nginx || echo "⚠️ Failed to restart nginx container"
    elif systemctl is-active --quiet nginx; then
        systemctl restart nginx || echo "⚠️ Failed to restart nginx service"
    else
        echo "ℹ️ No nginx service found to restart"
    fi
}

# Main logic
case "${1:-auto}" in
    "self-signed")
        generate_self_signed
        restart_nginx
        ;;
    "letsencrypt")
        if request_letsencrypt; then
            restart_nginx
        else
            echo "⚠️ Let's Encrypt failed, keeping existing certificates"
        fi
        ;;
    "check")
        check_certificates
        ;;
    "renew")
        if check_certificates; then
            echo "ℹ️ Certificate is still valid, no renewal needed"
        else
            echo "🔄 Attempting certificate renewal..."
            if request_letsencrypt; then
                restart_nginx
            else
                echo "❌ Renewal failed"
                exit 1
            fi
        fi
        ;;
    "auto"|*)
        echo "🤖 Auto mode: checking existing certificates..."
        if check_certificates; then
            echo "✅ Valid certificates found, nothing to do"
        else
            echo "🔧 No valid certificates, generating self-signed..."
            generate_self_signed
            
            # Try to get Let's Encrypt if credentials exist
            if [[ -f /root/.secrets/cloudflare.ini ]]; then
                echo "🔄 Attempting to upgrade to Let's Encrypt..."
                if request_letsencrypt; then
                    echo "✅ Upgraded to Let's Encrypt certificates"
                else
                    echo "⚠️ Let's Encrypt failed, using self-signed certificates"
                fi
            else
                echo "ℹ️ No Cloudflare credentials, using self-signed certificates"
            fi
            
            restart_nginx
        fi
        ;;
esac

echo "🔒 SSL Certificate Manager completed"
