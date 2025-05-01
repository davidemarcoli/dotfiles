#!/bin/bash

# Directory for monitor configuration files
CONFIG_DIR="$HOME/.config/hypr/monitors"
OUTPUT_FILE="$CONFIG_DIR/current.conf"

# Create the monitor configs directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Function to get a unique identifier for the current monitor setup
get_monitor_signature() {
    # Get monitor information and extract names and model information
    hyprctl monitors -j | jq -r '.[] | "\(.make)-\(.model)-\(.serial)"' | sort | tr '\n' ':'
}

# Get the current monitor signature
CURRENT_SIGNATURE=$(get_monitor_signature)

# Create a default configuration
create_default_config() {
    echo "# Default configuration - created $(date)" > "$OUTPUT_FILE"
    echo "monitor=,preferred,auto,auto" >> "$OUTPUT_FILE"
}

# Check if we have a configuration file for this monitor signature
if [ -f "$CONFIG_DIR/signatures.conf" ]; then
    # Look up the signature in the signatures file
    CONFIG_NAME=$(grep "^$CURRENT_SIGNATURE=" "$CONFIG_DIR/signatures.conf" | cut -d= -f2)
    
    if [ -n "$CONFIG_NAME" ] && [ -f "$CONFIG_DIR/$CONFIG_NAME.conf" ]; then
        # Found a matching config, copy it to current.conf
        cp "$CONFIG_DIR/$CONFIG_NAME.conf" "$OUTPUT_FILE"
        echo "Applied monitor configuration: $CONFIG_NAME"
        exit 0
    fi
fi

# No matching configuration found, create default
create_default_config
echo "No matching monitor configuration found, using default"