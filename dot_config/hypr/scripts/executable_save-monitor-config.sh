#!/bin/bash

# Directory for monitor configuration files
CONFIG_DIR="$HOME/.config/hypr/monitors"

# Create the monitor configs directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Check if a profile name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <profile_name>"
    echo "Example: $0 home-office"
    exit 1
fi

PROFILE_NAME="$1"
CONFIG_FILE="$CONFIG_DIR/$PROFILE_NAME.conf"
SIGNATURES_FILE="$CONFIG_DIR/signatures.conf"

# Function to get a unique identifier for the current monitor setup
get_monitor_signature() {
    hyprctl monitors -j | jq -r '.[] | "\(.make)-\(.model)-\(.serial)"' | sort | tr '\n' ':'
}

# Get the current monitor signature
CURRENT_SIGNATURE=$(get_monitor_signature)

# Save the current monitor configuration
echo "# Monitor configuration for $PROFILE_NAME - created $(date)" > "$CONFIG_FILE"
echo "# Monitors detected:" >> "$CONFIG_FILE"

# Add monitor information
while read -r MONITOR_INFO; do
    NAME=$(echo "$MONITOR_INFO" | jq -r '.name')
    WIDTH=$(echo "$MONITOR_INFO" | jq -r '.width')
    HEIGHT=$(echo "$MONITOR_INFO" | jq -r '.height')
    REFRESH=$(echo "$MONITOR_INFO" | jq -r '.refreshRate')
    X=$(echo "$MONITOR_INFO" | jq -r '.x')
    Y=$(echo "$MONITOR_INFO" | jq -r '.y')
    SCALE=$(echo "$MONITOR_INFO" | jq -r '.scale')
    TRANSFORM=$(echo "$MONITOR_INFO" | jq -r '.transform')
    
    # Add a comment with monitor details
    echo "# $NAME: $(echo "$MONITOR_INFO" | jq -r '.description')" >> "$CONFIG_FILE"
    
    # Add the monitor configuration line
    echo "monitor=$NAME,${WIDTH}x${HEIGHT}@${REFRESH%.*},${X}x${Y},${SCALE}" >> "$CONFIG_FILE"
    
    # Add transform if not 0
    if [ "$TRANSFORM" != "0" ]; then
        echo "monitor=$NAME,transform,$TRANSFORM" >> "$CONFIG_FILE"
    fi
    
    echo "" >> "$CONFIG_FILE"
done < <(hyprctl monitors -j | jq -c '.[]')

# Save the signature to configuration mapping
if [ -f "$SIGNATURES_FILE" ]; then
    # Remove existing entry for this signature if it exists
    grep -v "^$CURRENT_SIGNATURE=" "$SIGNATURES_FILE" > "$SIGNATURES_FILE.tmp"
    mv "$SIGNATURES_FILE.tmp" "$SIGNATURES_FILE"
fi

# Add the new signature mapping
echo "$CURRENT_SIGNATURE=$PROFILE_NAME" >> "$SIGNATURES_FILE"

echo "Monitor configuration saved as '$PROFILE_NAME'"
echo "This configuration will be automatically applied when these monitors are connected again"