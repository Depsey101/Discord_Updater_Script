#!/bin/bash
set -e

# Where to install/update from
DISCORD_URL="https://discord.com/api/download?platform=linux&format=deb"
TMP_DEB="/tmp/discord-latest.deb"
LOG_FILE="/tmp/discord-update.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if Discord is already running
if pgrep -x "Discord" > /dev/null; then
    log "Discord is already running."
    exit 0
fi

# Check for internet connectivity
if ! wget -q --spider --timeout=5 "https://discord.com"; then
    log "No internet connection detected. Launching Discord without update check..."
    discord &
    exit 0
fi

# Get currently installed Discord version (if any)
INSTALLED_VERSION=""
if dpkg -l | grep -q "^ii.*discord"; then
    INSTALLED_VERSION=$(dpkg -l discord 2>/dev/null | grep "^ii" | awk '{print $3}')
    log "Currently installed version: $INSTALLED_VERSION"
fi

# Download the latest .deb
log "Checking for latest Discord build..."
if ! wget -qO "$TMP_DEB" "$DISCORD_URL"; then
    log "Download failed. Launching existing Discord installation..."
    notify-send "Discord Update" "Update check failed. Launching existing version." -i discord
    discord &
    exit 0
fi

# Get version from the downloaded package
AVAILABLE_VERSION=$(dpkg-deb -f "$TMP_DEB" Version 2>/dev/null)
log "Available version: $AVAILABLE_VERSION"

# Compare versions if both are available
if [ -n "$INSTALLED_VERSION" ] && [ -n "$AVAILABLE_VERSION" ]; then
    if [ "$INSTALLED_VERSION" = "$AVAILABLE_VERSION" ]; then
        log "Discord is already up to date (version $INSTALLED_VERSION)."
        rm -f "$TMP_DEB"
        discord &
        exit 0
    fi
    log "Update available: $INSTALLED_VERSION → $AVAILABLE_VERSION"
fi

# Install/update with better error handling
log "Installing Discord version $AVAILABLE_VERSION..."

# First, try to install
if sudo dpkg -i "$TMP_DEB" 2>&1 | tee -a "$LOG_FILE"; then
    notify-send "Discord Updated" "Discord has been updated to version $AVAILABLE_VERSION." -i discord
    log "Update successful!"
    UPDATE_SUCCESS=true
else
    log "dpkg installation encountered issues. Attempting to fix dependencies..."
    
    # Try to fix broken dependencies
    if sudo apt-get install -f -y 2>&1 | tee -a "$LOG_FILE"; then
        notify-send "Discord Updated" "Discord has been updated to version $AVAILABLE_VERSION." -i discord
        log "Update successful after fixing dependencies!"
        UPDATE_SUCCESS=true
    else
        notify-send "Discord Update Failed" "Could not install update. Check $LOG_FILE for details." -i discord -u critical
        log "Update failed. Check the log for details."
        UPDATE_SUCCESS=false
    fi
fi

# Clean up
rm -f "$TMP_DEB"

# Launch Discord
log "Launching Discord..."
nohup discord > /dev/null 2>&1 &
disown

# Show log location if update failed
if [ "$UPDATE_SUCCESS" = false ]; then
    log "Update failed. Log saved to: $LOG_FILE"
    echo "Check $LOG_FILE for error details"
fi