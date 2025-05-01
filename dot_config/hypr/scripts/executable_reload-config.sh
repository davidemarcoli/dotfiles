#!/bin/bash

# Print a nice header
echo "╔═════════════════════════════════════╗"
echo "║ Reloading all system configurations ║"
echo "╚═════════════════════════════════════╝"

# Kill existing processes that we'll restart
echo "► Stopping Waybar..."
killall waybar

# Optional: Reload hyprpaper if you're using it
if pgrep -x "hyprpaper" > /dev/null; then
    echo "► Reloading Hyprpaper..."
    killall hyprpaper
    hyprpaper &
fi

# Optional: Reload hypridle if you're using it
if pgrep -x "hypridle" > /dev/null; then
    echo "► Reloading Hypridle..."
    killall hypridle
    hypridle &
fi

# Reload Hyprland configuration
echo "► Reloading Hyprland configuration..."
hyprctl reload

# Give Hyprland a moment to reload
sleep 0.5

# Start Waybar
echo "► Starting Waybar..."
waybar &

echo "✓ All configurations reloaded successfully!"