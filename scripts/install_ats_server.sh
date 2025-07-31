#!/bin/bash
# Install ATS Dedicated Server via SteamCMD

set -e

echo "Installing ATS Dedicated Server..."

# SteamCMD installation directory
STEAMCMD_DIR="/opt/steamcmd"
ATS_DIR="/app/ats-server"

# ATS dedicated server Steam app ID (from official documentation)
ATS_APP_ID="2239530"  # American Truck Simulator Dedicated Server

# Install/update ATS dedicated server
echo "Running SteamCMD to install/update ATS dedicated server..."
$STEAMCMD_DIR/steamcmd.sh +force_install_dir "$ATS_DIR" \
    +login anonymous \
    +app_update "$ATS_APP_ID" validate \
    +quit

echo "ATS dedicated server installation completed."

echo "Installation script completed successfully."
