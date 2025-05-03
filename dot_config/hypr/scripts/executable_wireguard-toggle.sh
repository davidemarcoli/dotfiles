#!/bin/bash

# Get all WireGuard connections
WG_CONNECTIONS=($(nmcli -t -f TYPE,NAME connection show | grep "wireguard" | cut -d: -f2))

if [ ${#WG_CONNECTIONS[@]} -eq 0 ]; then
    notify-send "WireGuard" "No WireGuard profiles found" -i network-vpn-disconnected
    exit 1
fi

# Check if any WireGuard connection is active
ACTIVE_CONNECTION=$(nmcli -t -f TYPE,NAME,ACTIVE connection show | grep "wireguard" | grep ":yes" | cut -d: -f2)

if [ -n "$ACTIVE_CONNECTION" ]; then
    # Disconnect active connection
    nmcli connection down "$ACTIVE_CONNECTION"
    notify-send "WireGuard" "Disconnected from $ACTIVE_CONNECTION" -i network-vpn-disconnected
else
    # If only one connection exists, connect to it
    if [ ${#WG_CONNECTIONS[@]} -eq 1 ]; then
        nmcli connection up "${WG_CONNECTIONS[0]}"
        notify-send "WireGuard" "Connected to ${WG_CONNECTIONS[0]}" -i network-vpn
    else
        # If multiple connections exist, use wofi to select
        SELECTED=$(printf '%s\n' "${WG_CONNECTIONS[@]}" | wofi --dmenu --prompt "Select WireGuard connection")
        if [ -n "$SELECTED" ]; then
            nmcli connection up "$SELECTED"
            notify-send "WireGuard" "Connected to $SELECTED" -i network-vpn
        fi
    fi
fi