#!/bin/bash
# Define log file
LOG_FILE="/tmp/hyprlock.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Function for logging
log() {
    echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
}

# Check if hyprlock is already running
if pidof hyprlock > /dev/null; then
    log "Hyprlock is already running"
    exit 0
fi

# Start hyprlock
log "Attempting to start hyprlock"
hyprlock &
HYPRLOCK_PID=$!

# Wait a moment to ensure hyprlock has started
sleep 0.5

# Verify hyprlock is still running
if ! kill -0 $HYPRLOCK_PID 2>/dev/null; then
    log "ERROR: Hyprlock failed to start or crashed immediately"
    exit 1
fi

log "Hyprlock started successfully with PID $HYPRLOCK_PID"
exit 0