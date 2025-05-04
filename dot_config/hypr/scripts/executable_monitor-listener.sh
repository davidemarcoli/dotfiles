#!/bin/bash

# Monitor event listener for Hyprland
# Automatically reloads monitor configuration when monitors are connected/disconnected

SOCKET_PATH="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

reload_monitor_config() {
    echo "Monitor event detected. Reloading configuration..."
    ~/.config/hypr/scripts/monitor-config.sh
    hyprctl reload
    echo "Monitor configuration reloaded."
}

# Listen to Hyprland socket for monitor events
socat -U - UNIX-CONNECT:"$SOCKET_PATH" | while read -r line; do
    if [[ $line == monitoradded* ]] || [[ $line == monitorremoved* ]]; then
        sleep 1
        reload_monitor_config
    fi
done