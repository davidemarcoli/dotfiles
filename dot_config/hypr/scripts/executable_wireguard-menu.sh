#!/bin/bash

# Options
CONNECT="Connect to..."
DISCONNECT="Disconnect"
CREATE_NEW="Create New Connection"
EDIT="Edit Connections"

# Get current state
ACTIVE_CONNECTION=$(nmcli -t -f TYPE,NAME,ACTIVE connection show | grep "wireguard" | grep ":yes" | cut -d: -f2)

# Build menu
if [ -n "$ACTIVE_CONNECTION" ]; then
    OPTIONS="$DISCONNECT\n$CONNECT\n$EDIT"
else
    OPTIONS="$CONNECT\n$CREATE_NEW\n$EDIT"
fi

# Show menu
CHOICE=$(echo -e "$OPTIONS" | wofi --dmenu --prompt "WireGuard")

case "$CHOICE" in
    "$CONNECT")
        # Get all WireGuard connections
        WG_CONNECTIONS=($(nmcli -t -f TYPE,NAME connection show | grep "wireguard" | cut -d: -f2))
        SELECTED=$(printf '%s\n' "${WG_CONNECTIONS[@]}" | wofi --dmenu --prompt "Select connection")
        if [ -n "$SELECTED" ]; then
            nmcli connection up "$SELECTED"
        fi
        ;;
    "$DISCONNECT")
        if [ -n "$ACTIVE_CONNECTION" ]; then
            nmcli connection down "$ACTIVE_CONNECTION"
        fi
        ;;
    "$CREATE_NEW")
        # Open terminal with nmtui for connection editing
        alacritty -e nmtui-connect
        ;;
    "$EDIT")
        # Open terminal with nmtui for connection editing
        alacritty -e nmtui-edit
        ;;
esac