#!/bin/bash

# Get all WireGuard connections
WG_CONNECTIONS=$(nmcli -t -f TYPE,NAME,ACTIVE connection show | grep "wireguard" | cut -d: -f2,3)

if [ -z "$WG_CONNECTIONS" ]; then
    echo -e '{"text": "󰕑", "tooltip": "No WireGuard profiles", "class": "disconnected"}'
    exit 0
fi

# Check if any WireGuard connection is active
ACTIVE_CONNECTION=$(echo "$WG_CONNECTIONS" | grep ":yes" | cut -d: -f1)

if [ -n "$ACTIVE_CONNECTION" ]; then
    # Get connection details
    DEVICE=$(nmcli -t -f GENERAL.DEVICES connection show "$ACTIVE_CONNECTION" | cut -d: -f2)
    STATE=$(nmcli -t -f GENERAL.STATE connection show "$ACTIVE_CONNECTION" | cut -d: -f2)
    IP4=$(nmcli -t -f IP4.ADDRESS connection show "$ACTIVE_CONNECTION" | cut -d: -f2)
    
    # Get VPN status from NetworkManager
    VPN_STATE=$(nmcli -t -f GENERAL.STATE connection show "$ACTIVE_CONNECTION" | cut -d: -f2)
    
    if [ "$VPN_STATE" = "activated" ]; then
        ICON="󰖂"
        CLASS="connected"
        TOOLTIP="Connection: $ACTIVE_CONNECTION, IP: $IP4, Device: $DEVICE, State: Connected"
    else
        ICON="󰖂"
        CLASS="connecting"
        TOOLTIP="Connection: $ACTIVE_CONNECTION, State: Connecting..."
    fi
    
    echo -e "{\"text\": \"$ICON\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
else
    # List available connections in tooltip
    CONNECTIONS_LIST=$(echo "$WG_CONNECTIONS" | cut -d: -f1 | sed 's/^/• /')
    echo -e "{\"text\": \"󰕑\", \"tooltip\": \"WireGuard disconnected! Available connections: $CONNECTIONS_LIST\", \"class\": \"disconnected\"}"
fi