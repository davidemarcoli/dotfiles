#!/bin/bash

entries="Lock\nLogout\nSuspend\nReboot\nShutdown"

selected=$(echo -e $entries | wofi --dmenu --insensitive --width 200 --height 250 --cache-file /dev/null | awk '{print tolower($1)}')

case $selected in
    lock)
        swaylock --color 000000 -f ;;
    logout)
        hyprctl dispatch exit ;;
    suspend)
        systemctl suspend ;;
    reboot)
        systemctl reboot ;;
    shutdown)
        systemctl poweroff ;;
esac
