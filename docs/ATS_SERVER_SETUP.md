# ATS Dedicated Server Setup Guide

This guide explains how to set up and run the American Truck Simulator dedicated server using Docker Compose.

## Prerequisites

1. **Server Packages Files**: The ATS dedicated server requires `server_packages.sii` and `server_packages.dat` files that must be generated from the ATS game client.

2. **Steam Server Logon Token** (Optional but recommended): For persistent server identity, get a token from https://steamcommunity.com/dev/managegameservers

## Quick Start

### 1. Using GitHub Actions (Automated)

The repository includes GitHub Actions that automatically deploy the server:

1. Fork this repository
2. Set up the required secrets in your GitHub repository settings:
   - `ATS_ROOT_PASSWORD`: Server password 
   - `CLOUDFLARE_API_TOKEN`: For DNS management (optional)
   - `CLOUDFLARE_ZONE_ID`: For DNS management (optional)
   - `DISCORD_WEBHOOK_URL`: For notifications (optional)
   - `NETDATA_CLAIM_TOKEN`: For monitoring (optional)
   - `NETDATA_CLAIM_ROOM`: For monitoring (optional)

3. Run the "Manage ATS Game Server" workflow

### 2. Manual Deployment

```bash
# Clone the repository
git clone https://github.com/nuniesmith/ats.git
cd ats

# Copy and edit environment file
cp .env.template .env
# Edit .env with your configuration

# Start services
./deploy-compose.sh
```

## Generating Server Packages Files

⚠️ **IMPORTANT**: You need to generate these files from the ATS game client:

1. Install American Truck Simulator on a computer
2. Enable console in `config.cfg`: `uset g_console "1"`
3. Start the game and load a map
4. Open console with `~` key
5. Run command: `export_server_packages`
6. Copy the generated `server_packages.sii` and `server_packages.dat` files to your server's `config/` directory

## Server Configuration

### Environment Variables

Key configuration options in `.env`:

```bash
# Server Identity
ATS_SERVER_NAME="Your Server Name"
ATS_SERVER_PASSWORD="your_password"
ATS_MAX_PLAYERS=8

# Network Configuration  
ATS_SERVER_PORT=27015
ATS_QUERY_PORT=27016

# Steam Integration
ATS_SERVER_LOGON_TOKEN="your_token_here"
STEAM_COLLECTION_ID=3530633316

# Server Behavior
ATS_SPEED_LIMITER=false
ATS_ENABLE_PVP=false
```

### Server Configuration File

The `config/server_config.sii` file controls server behavior:

- `lobby_name`: Server name in browser
- `password`: Server password
- `max_players`: Maximum players (limit: 8)
- `connection_dedicated_port`: TCP/UDP port for connections
- `query_dedicated_port`: Port for server queries
- `server_logon_token`: Steam server token
- `moderator_list`: Steam IDs of moderators

## Port Configuration

### Required Ports

- **27015/tcp & 27015/udp**: Game server port
- **27016/tcp & 27016/udp**: Query port  
- **80/tcp**: Web interface
- **443/tcp**: HTTPS (if SSL enabled)

### Port Forwarding

For servers behind NAT, forward these ports:
- TCP: 27015, 27016, 80, 443
- UDP: 27015, 27016

## Management Commands

Use the management script for common operations:

```bash
# Start services
./ats-manager.sh start

# Check status
./ats-manager.sh status

# View logs
./ats-manager.sh logs ats-server

# Restart services
./ats-manager.sh restart

# Update services
./ats-manager.sh update
```

## Docker Services

The setup includes these services:

- **ats-server**: ATS dedicated game server
- **ats-api**: Node.js API for server management
- **ats-web**: React web interface
- **redis**: Session storage
- **nginx**: Reverse proxy
- **netdata**: Monitoring (optional)

## Troubleshooting

### Common Issues

1. **"Server packages file not found"**
   - Generate `server_packages.sii` and `server_packages.dat` from game client
   - Copy files to `config/` directory

2. **"SteamAPI_Init() failed"**
   - Server needs `steamclient.so` library
   - Handled automatically by startup script

3. **Server not visible in browser**
   - Check port forwarding
   - Verify `connection_dedicated_port` and `query_dedicated_port`
   - Use server logon token for persistent identity

4. **Connection issues**
   - Use direct search with server ID
   - Check firewall rules
   - Verify virtual ports (100-200 range)

### Log Files

Check these files for debugging:
- `logs/server.log`: Server output
- `logs/server.crash.txt`: Crash logs (if applicable)
- Docker logs: `docker logs ats-dedicated-server`

### Admin Commands

Moderators can use these chat commands:
- `/set_time <HH:MM>`: Change game time
- `/set_rain_factor <0-1>`: Control rain
- `/help`: Show available commands

## Server Performance

### Recommended Specs

- **CPU**: 2+ cores
- **RAM**: 4GB minimum, 8GB recommended  
- **Network**: Stable internet with low latency
- **Storage**: 10GB+ free space

### Optimization

- Use SSD storage for better performance
- Configure adequate ulimits for file descriptors
- Monitor resource usage with included Netdata

## Security

- Use strong passwords
- Keep server software updated
- Use firewall to restrict access
- Create dedicated Steam account for server
- Regular backups of configuration

## Support

- Check server logs for errors
- Use GitHub Issues for problems
- Refer to official ATS server documentation
- Monitor server status via web interface
