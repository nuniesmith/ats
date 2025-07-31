#!/bin/bash
# Start ATS Dedicated Server in Docker

set -e

echo "Starting ATS Dedicated Server..."

# Server configuration
ATS_DIR="/app/ats-server"
CONFIG_DIR="$ATS_DIR/config"
LOG_DIR="$ATS_DIR/logs"

# Default environment variables
SERVER_NAME="${ATS_SERVER_NAME:-ATS Dedicated Server}"
SERVER_PASSWORD="${ATS_SERVER_PASSWORD:-ruby}"
MAX_PLAYERS="${ATS_MAX_PLAYERS:-8}"
SERVER_PORT="${ATS_SERVER_PORT:-27015}"
QUERY_PORT="${ATS_QUERY_PORT:-27016}"
WELCOME_MESSAGE="${ATS_WELCOME_MESSAGE:-Welcome to our ATS server!}"
LOGON_TOKEN="${ATS_SERVER_LOGON_TOKEN:-${ATS_LOGON_TOKEN:-}}"

echo "Server Configuration:"
echo "  Name: $SERVER_NAME"
echo "  Port: $SERVER_PORT"
echo "  Query Port: $QUERY_PORT"
echo "  Max Players: $MAX_PLAYERS"
echo "  Password Protected: $([ -n "$SERVER_PASSWORD" ] && echo "Yes" || echo "No")"

# Ensure directories exist
mkdir -p "$LOG_DIR"
mkdir -p "$CONFIG_DIR"

# Generate server configuration if it doesn't exist
if [ ! -f "$CONFIG_DIR/server_config.sii" ]; then
    echo "Generating server configuration..."
    cat > "$CONFIG_DIR/server_config.sii" << EOF
SiiNunit
{
server_config : .config {
    lobby_name: "$SERVER_NAME"
    description: "$WELCOME_MESSAGE"
    welcome_message: "$WELCOME_MESSAGE"
    password: "$SERVER_PASSWORD"
    max_players: $MAX_PLAYERS
    max_vehicles_total: 100
    max_ai_vehicles_player: 50
    max_ai_vehicles_player_spawn: 50
    connection_virtual_port: 100
    query_virtual_port: 101
    connection_dedicated_port: $SERVER_PORT
    query_dedicated_port: $QUERY_PORT
    server_logon_token: "$LOGON_TOKEN"
    player_damage: true
    traffic: true
    hide_in_company: false
    hide_colliding: true
    force_speed_limiter: ${ATS_SPEED_LIMITER:-false}
    mods_optioning: true
    timezones: 0
    service_no_collision: false
    in_menu_ghosting: false
    name_tags: true
    friends_only: false
    show_server: true
    moderator_list: 0
    mods: .mods {
    }
}
}
EOF
fi

# Generate server packages configuration if it doesn't exist
if [ ! -f "$CONFIG_DIR/server_packages.sii" ]; then
    echo "Generating server packages configuration..."
    if [ -n "$STEAM_COLLECTION_ID" ]; then
        cat > "$CONFIG_DIR/server_packages.sii" << EOF
SiiNunit
{
server_packages : .server_packages {
    packages[0]: "steam.$STEAM_COLLECTION_ID"
}
}
EOF
    else
        cat > "$CONFIG_DIR/server_packages.sii" << EOF
SiiNunit
{
server_packages : .server_packages {
}
}
EOF
    fi
fi

# Create a basic server_packages.dat file if it doesn't exist
if [ ! -f "$CONFIG_DIR/server_packages.dat" ]; then
    echo "Creating basic server_packages.dat file..."
    echo "# Basic server packages data file" > "$CONFIG_DIR/server_packages.dat"
    echo "# This should be generated from the game client using 'export_server_packages' command" >> "$CONFIG_DIR/server_packages.dat"
    echo "# See ATS documentation for proper generation" >> "$CONFIG_DIR/server_packages.dat"
fi

# Create log file
touch "$LOG_DIR/server.log"

# Function to handle shutdown gracefully
shutdown_handler() {
    echo "Received shutdown signal, stopping ATS server..."
    if [ -n "$ATS_PID" ]; then
        kill -TERM "$ATS_PID"
        wait "$ATS_PID"
    fi
    echo "ATS server stopped."
    exit 0
}

# Set up signal handlers
trap shutdown_handler SIGTERM SIGINT

# Change to server directory
cd "$ATS_DIR"

# Find the ATS server executable (based on documentation)
ATS_EXECUTABLE=""
if [ -f "bin/linux_x64/amtrucks_server" ]; then
    ATS_EXECUTABLE="bin/linux_x64/amtrucks_server"
elif [ -f "bin/amtrucks_server" ]; then
    ATS_EXECUTABLE="bin/amtrucks_server"
elif [ -f "amtrucks_server" ]; then
    ATS_EXECUTABLE="amtrucks_server"
else
    echo "ERROR: ATS server executable not found!"
    echo "Expected locations:"
    echo "  - bin/linux_x64/amtrucks_server"
    echo "  - bin/amtrucks_server" 
    echo "  - amtrucks_server"
    echo ""
    echo "Available files in $ATS_DIR:"
    find . -name "*server*" -o -name "*amtrucks*" | head -10
    exit 1
fi

echo "Found ATS server executable: $ATS_EXECUTABLE"

# Make sure it's executable
chmod +x "$ATS_EXECUTABLE"

# Set up Steam library path for Linux (required for steamclient.so)
export LD_LIBRARY_PATH="$ATS_DIR/linux64:$LD_LIBRARY_PATH"

# Create steamclient.so link if it doesn't exist (required by documentation)
if [ ! -f "$HOME/.steam/sdk64/steamclient.so" ]; then
    echo "Creating Steam client library link..."
    mkdir -p "$HOME/.steam/sdk64"
    if [ -f "$ATS_DIR/linux64/steamclient.so" ]; then
        ln -sf "$ATS_DIR/linux64/steamclient.so" "$HOME/.steam/sdk64/steamclient.so"
        echo "Linked steamclient.so from ATS directory"
    elif [ -f "/usr/lib/steam/steamclient.so" ]; then
        ln -sf "/usr/lib/steam/steamclient.so" "$HOME/.steam/sdk64/steamclient.so"
        echo "Linked steamclient.so from system Steam"
    else
        echo "WARNING: steamclient.so not found! Server may fail to start."
    fi
fi

# Build command line arguments based on documentation
ARGS=()
ARGS+=("-server" "$CONFIG_DIR/server_packages.sii")
ARGS+=("-server_cfg" "$CONFIG_DIR/server_config.sii")
ARGS+=("-homedir" ".")
ARGS+=("-nosingle")  # Enable multiple instances

echo "Starting ATS server with arguments: ${ARGS[*]}"

# Start the server and capture PID
"./$ATS_EXECUTABLE" "${ARGS[@]}" > "$LOG_DIR/server.log" 2>&1 &
ATS_PID=$!

echo "ATS server started with PID: $ATS_PID"
echo "Log file: $LOG_DIR/server.log"

# Monitor the process
while kill -0 "$ATS_PID" 2>/dev/null; do
    sleep 10
done

echo "ATS server process ended."
wait "$ATS_PID"
EXIT_CODE=$?

echo "ATS server exited with code: $EXIT_CODE"
exit $EXIT_CODE
