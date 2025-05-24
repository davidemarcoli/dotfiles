#!/bin/bash
if [ "$(cat /sys/class/power_supply/AC/online)" -eq "0" ]; then
    # When on battery, just suspend (hypridle will handle locking)
    systemctl suspend
else
    # When plugged in, just lock
    loginctl lock-session
fi