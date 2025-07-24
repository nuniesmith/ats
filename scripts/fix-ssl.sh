#!/bin/bash
# Script to update ATS deployment with proper SSL configuration
# Run this on your server to fix the SSL/HTTPS issues

set -e

echo "🔧 Updating ATS deployment for proper SSL/HTTPS handling..."

# Check if we're in the right directory
if [[ ! -f "docker-compose.yml" ]]; then
    echo "❌ docker-compose.yml not found. Make sure you're in /opt/ats directory"
    exit 1
fi

# Check if SSL certificates exist
DOMAIN_NAME="ats.7gram.xyz"
if [[ -f "/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem" ]]; then
    echo "✅ SSL certificates found for $DOMAIN_NAME"
    HAS_SSL=true
else
    echo "⚠️ No SSL certificates found for $DOMAIN_NAME"
    echo "   The site will work on HTTP but not HTTPS"
    HAS_SSL=false
fi

# Stop current containers
echo "🛑 Stopping current containers..."
docker-compose down

# Pull latest images to ensure we have the updated configuration
echo "📥 Pulling latest container images..."
docker-compose pull

# Start containers with new configuration
echo "🚀 Starting containers with updated configuration..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Check container status
echo "📊 Container status:"
docker-compose ps

# Test HTTP access
echo "🌐 Testing HTTP access..."
if curl -s -f http://localhost/nginx-health >/dev/null; then
    echo "✅ HTTP access working (http://localhost)"
else
    echo "❌ HTTP access failed"
fi

# Test HTTPS access if certificates exist
if [[ "$HAS_SSL" == "true" ]]; then
    echo "🔒 Testing HTTPS access..."
    if curl -s -f -k https://localhost/nginx-health >/dev/null; then
        echo "✅ HTTPS access working (https://localhost)"
    else
        echo "❌ HTTPS access failed"
        echo "🔍 Checking nginx configuration..."
        docker exec ats-nginx-proxy nginx -t || echo "Nginx config test failed"
    fi
fi

# Show access information
echo ""
echo "📋 Access Information:"
echo "  HTTP:  http://$(hostname -I | awk '{print $1}') or http://ats.7gram.xyz"

if [[ "$HAS_SSL" == "true" ]]; then
    echo "  HTTPS: https://$(hostname -I | awk '{print $1}') or https://ats.7gram.xyz"
else
    echo "  HTTPS: Not available (no SSL certificates)"
    echo ""
    echo "💡 To enable HTTPS:"
    echo "   1. Ensure Cloudflare API token is configured"
    echo "   2. Run the deployment workflow again"
    echo "   3. Or manually request certificates with certbot"
fi

echo ""
echo "🔍 To check logs:"
echo "  docker-compose logs -f nginx"
echo "  docker-compose logs -f ats-web"
echo "  docker-compose logs -f ats-api"

echo ""
echo "✅ Update complete!"
