#!/bin/bash
# ~/.config/hypr/scripts/capture.sh

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
VIDEO_DIR="$HOME/Videos/Recordings"
mkdir -p "$SCREENSHOT_DIR" "$VIDEO_DIR"

# Function to show action menu with wofi
show_action_menu() {
    local file="$1"
    
    action=$(echo -e "Open\nCopy to Clipboard\nOpen Folder\nEdit\nDelete" | wofi --dmenu --prompt "Screenshot Action" --cache-file=/dev/null)
    
    case "$action" in
        "Open")
            xdg-open "$file"
            ;;
        "Copy to Clipboard")
            wl-copy < "$file"
            notify-send "Screenshot" "Copied to clipboard"
            ;;
        "Open Folder")
            xdg-open "$SCREENSHOT_DIR"
            ;;
        "Edit")
            gimp "$file" &  # Or your preferred editor
            ;;
        "Delete")
            rm "$file"
            notify-send "Screenshot" "Deleted"
            ;;
    esac
}

case "$1" in
    screenshot)
        FILE="$SCREENSHOT_DIR/$(date +%Y-%m-%d_%H-%M-%S).png"
        case "$2" in
            area)
                grimblast save area "$FILE"
                TYPE="Area"
                ;;
            screen)
                grimblast save screen "$FILE"
                TYPE="Screen"
                ;;
            window)
                grimblast save active "$FILE"
                TYPE="Window"
                ;;
        esac
        
        # Show notification with preview, clicking it will trigger the menu
        dunstify -i "$FILE" -a "Screenshot" --action="default,Open Menu" "Screenshot" "$TYPE saved: $(basename "$FILE")"
        
        # If the notification was clicked (dunstify returns "default" when clicked)
        if [ $? -eq 0 ]; then
            show_action_menu "$FILE"
        fi
        ;;
    record)
        if pgrep -x "wf-recorder" > /dev/null; then
            pkill -INT wf-recorder
            notify-send "Recording" "Stopped"
        else
            case "$2" in
                area)
                    wf-recorder -g "$(slurp)" -f "$VIDEO_DIR/$(date +%Y-%m-%d_%H-%M-%S).mp4" &
                    notify-send "Recording" "Area recording started"
                    ;;
                screen)
                    wf-recorder -f "$VIDEO_DIR/$(date +%Y-%m-%d_%H-%M-%S).mp4" &
                    notify-send "Recording" "Screen recording started"
                    ;;
            esac
        fi
        ;;
esac