#!/bin/bash
# Quick fix to get ATS working on HTTP immediately
# Run this on your server to fix the immediate SSL protocol error

echo "🔧 Quick fix: Updating nginx to serve HTTP properly..."

# Create a temporary nginx config that works without SSL
cat > /tmp/nginx-http-only.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;

    # Basic Settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Gzip Settings
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Upstream definitions
    upstream ats_web {
        server ats-web-app:80;
    }

    upstream ats_api {
        server ats-api-server:3001;
    }

    # HTTP server block
    server {
        listen 80 default_server;
        server_name _;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

        # Main web application
        location / {
            proxy_pass http://ats_web;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # API routes
        location /api {
            proxy_pass http://ats_api;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }

        # WebSocket proxy for Socket.IO
        location /socket.io {
            proxy_pass http://ats_api;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Health check endpoint
        location /nginx-health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Update the nginx config
echo "📝 Updating nginx configuration..."
cp /tmp/nginx-http-only.conf /opt/ats/config/nginx.conf

# Restart nginx container
echo "🔄 Restarting nginx container..."
cd /opt/ats
docker-compose restart nginx

# Wait a moment
sleep 10

# Test the fix
echo "🔍 Testing HTTP access..."
if curl -s -f http://localhost/nginx-health >/dev/null; then
    echo "✅ HTTP access working!"
    echo ""
    echo "🌐 Your site should now be accessible at:"
    echo "   http://$(hostname -I | awk '{print $1}')"
    echo "   http://ats.7gram.xyz (if DNS points to this server)"
    echo ""
    echo "⚠️ Note: This is HTTP only. For HTTPS, run the full deployment workflow"
    echo "   or use the fix-ssl.sh script after obtaining SSL certificates."
else
    echo "❌ Still having issues. Check logs with: docker-compose logs nginx"
fi
