#!/bin/bash
# ~/.config/hypr/scripts/ncspot-control.sh
# Control ncspot via socket commands

SOCKET_PATH="/run/user/$UID/ncspot/ncspot.sock"

# Check if ncspot socket exists
if [ ! -S "$SOCKET_PATH" ]; then
    notify-send "ncspot" "ncspot is not running" -i audio-x-generic
    alacritty -e ncspot &
fi

# Function to send command to ncspot
send_command() {
    local command="$1"
    echo "$command" | nc -U "$SOCKET_PATH" 2>/dev/null || {
        notify-send "ncspot" "Failed to send command: $command" -i dialog-error
        exit 1
    }
}

# Parse command line argument
case "$1" in
    "playpause"|"toggle")
        send_command "playpause"
        ;;
    "play")
        send_command "play"
        ;;
    "pause")
        send_command "pause"
        ;;
    "next")
        send_command "next"
        ;;
    "previous"|"prev")
        send_command "previous"
        ;;
    "stop")
        send_command "stop"
        ;;
    "volup")
        send_command "volup 5"
        ;;
    "voldown")
        send_command "voldown 5"
        ;;
    "like")
        send_command "save"
        notify-send "ncspot" "Track saved to library" -i emblem-favorite
        ;;
    "dislike")
        send_command "delete"
        notify-send "ncspot" "Track removed from library" -i edit-delete
        ;;
    "open")
        # Open ncspot in terminal
        alacritty -e ncspot &
        ;;
    *)
        echo "Usage: $0 {playpause|play|pause|next|previous|stop|volup|voldown|like|dislike|open}"
        echo "Available commands:"
        echo "  playpause/toggle - Toggle play/pause"
        echo "  play            - Start playing"
        echo "  pause           - Pause playback"
        echo "  next            - Skip to next track"
        echo "  previous/prev   - Go to previous track"
        echo "  stop            - Stop playback"
        echo "  volup           - Increase volume by 5%"
        echo "  voldown         - Decrease volume by 5%"
        echo "  like            - Save current track to library"
        echo "  dislike         - Remove current track from library"
        echo "  open            - Open ncspot in terminal"
        exit 1
        ;;
esac