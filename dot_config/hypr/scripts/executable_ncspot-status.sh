#!/bin/bash
# ~/.config/hypr/scripts/ncspot-status.sh
# Waybar module for ncspot current playing track

SOCKET_PATH="/run/user/$UID/ncspot/ncspot.sock"
MAX_LENGTH=50

# Check if ncspot socket exists
if [ ! -S "$SOCKET_PATH" ]; then
    echo '{"text": "", "tooltip": "ncspot not running", "class": "not-running"}'
    exit 0
fi

# Get current track info with timeout (just connect to get status, don't send commands)
TRACK_INFO=$(timeout 2 nc -W 1 -U "$SOCKET_PATH" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$TRACK_INFO" ]; then
    echo '{"text": "", "tooltip": "No connection to ncspot", "class": "no-connection"}'
    exit 0
fi

# Parse JSON and extract info
TITLE=$(echo "$TRACK_INFO" | jq -r '.playable.title // empty' 2>/dev/null)
ARTIST=$(echo "$TRACK_INFO" | jq -r '.playable.artists[0] // empty' 2>/dev/null)
ALBUM=$(echo "$TRACK_INFO" | jq -r '.playable.album // empty' 2>/dev/null)
DURATION=$(echo "$TRACK_INFO" | jq -r '.playable.duration // empty' 2>/dev/null)
PLAYING_STATUS=$(echo "$TRACK_INFO" | jq -r '.mode | keys[0] // empty' 2>/dev/null)

# Check if we got valid data
if [ -z "$TITLE" ] || [ "$TITLE" = "null" ]; then
    echo '{"text": "", "tooltip": "Nothing playing", "class": "stopped"}'
    exit 0
fi

# Format duration (from milliseconds to mm:ss)
if [ -n "$DURATION" ] && [ "$DURATION" != "null" ]; then
    DURATION_SEC=$((DURATION / 1000))
    DURATION_MIN=$((DURATION_SEC / 60))
    DURATION_SEC=$((DURATION_SEC % 60))
    FORMATTED_DURATION=$(printf "%d:%02d" $DURATION_MIN $DURATION_SEC)
else
    FORMATTED_DURATION=""
fi

# Create display text
if [ -n "$ARTIST" ] && [ "$ARTIST" != "null" ]; then
    DISPLAY_TEXT="$ARTIST - $TITLE"
else
    DISPLAY_TEXT="$TITLE"
fi

# Truncate if too long
if [ ${#DISPLAY_TEXT} -gt $MAX_LENGTH ]; then
    DISPLAY_TEXT="${DISPLAY_TEXT:0:$((MAX_LENGTH-3))}..."
fi

# Create tooltip
TOOLTIP="$TITLE"
if [ -n "$ARTIST" ] && [ "$ARTIST" != "null" ]; then
    TOOLTIP="$ARTIST - $TITLE"
fi
if [ -n "$ALBUM" ] && [ "$ALBUM" != "null" ]; then
    TOOLTIP="$TOOLTIP\nAlbum: $ALBUM"
fi
if [ -n "$FORMATTED_DURATION" ]; then
    TOOLTIP="$TOOLTIP\nDuration: $FORMATTED_DURATION"
fi

# Determine icon and class based on playing status
case "$PLAYING_STATUS" in
    "Playing")
        ICON="󰝚"
        CLASS="playing"
        ;;
    "Paused")
        ICON="󰏤"
        CLASS="paused"
        ;;
    *)
        ICON="󰓇"
        CLASS="stopped"
        ;;
esac

# Output JSON for waybar
echo "{\"text\": \"$ICON $DISPLAY_TEXT\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"