#!/bin/bash

# First lock the screen
hyprlock &

if [ "$(cat /sys/class/power_supply/AC/online)" -eq "0" ]; then
    # Wait a moment for the lock screen to fully initialize
    sleep 1

    # Then suspend the system
    systemctl suspend
fi