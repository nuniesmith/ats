# ATS Server Management - Required GitHub Secrets
# =================================================

# 🏗️ Core Infrastructure Secrets
LINODE_CLI_TOKEN=                    # Linode API token for server provisioning
CLOUDFLARE_API_TOKEN=           # Cloudflare API token for DNS management  
CLOUDFLARE_ZONE_ID=             # Zone ID for 7gram.xyz domain
TAILSCALE_AUTH_KEY=             # Tailscale auth key for private networking (ephemeral, reusable)

# 🔐 Server Access & Security
ATS_ROOT_PASSWORD=              # Root password for ATS servers
ACTIONS_USER_PASSWORD=          # Password for GitHub Actions user account

# 💬 Discord Integration
DISCORD_WEBHOOK_URL=            # Discord webhook for deployment notifications
DISCORD_BOT_TOKEN=              # Optional: For advanced Discord features

# 🐳 Docker & Container Registry
DOCKER_USERNAME=                # Docker Hub username (for private images)
DOCKER_TOKEN=                   # Docker Hub access token

# 🌐 SSL & Domain Configuration
DOMAIN_NAME=ats.7gram.xyz       # Primary domain for the web interface
ADMIN_EMAIL=                    # Email for Let's Encrypt SSL certificates

# 🎮 ATS-Specific Configuration
ATS_SERVER_TOKEN=               # Steam server authentication token
ATS_DEFAULT_PASSWORD=ruby       # Default password for ATS servers
STEAM_COLLECTION_ID=3530633316  # Your Steam Workshop collection ID

# 📊 Monitoring (Optional)
NETDATA_CLAIM_TOKEN=            # Netdata monitoring claim token
NETDATA_CLAIM_ROOM=             # Netdata monitoring room ID
