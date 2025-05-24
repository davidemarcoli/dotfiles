#!/bin/bash

# # Debug information
# echo "Starting lock screen at $(date)" >> ~/.cache/hyprlock-debug.log

# #!/bin/bash
# export HYPRLAND_LOG_LEVEL=DEBUG
# export WAYLAND_DEBUG=1
# exec hyprlock "$@" 2>&1 | tee -a ~/.cache/hyprlock-debug.log

# # # Launch lock screen
# # hyprlock -v >> ~/.cache/hyprlock-debug.log 2>&1 
# exit_code=$?

# # Log exit status
# echo "Hyprlock exited with code $exit_code at $(date)" >> ~/.cache/hyprlock-debug.log

echo "Starting hyprlock at $(date)" >> ~/.cache/hyprlock-debug.log
echo "Checking for existing instances..." >> ~/.cache/hyprlock-debug.log
ps aux | grep hyprlock >> ~/.cache/hyprlock-debug.log

if pidof hyprlock; then
    echo "Hyprlock already running, exiting" >> ~/.cache/hyprlock-debug.log
    exit 0
fi

echo "No existing instance, starting hyprlock..." >> ~/.cache/hyprlock-debug.log
WAYLAND_DEBUG=1 hyprlock 2>&1 | tee -a ~/.cache/hyprlock-debug.log
EXIT_CODE=$?
echo "Hyprlock exited with code $EXIT_CODE at $(date)" >> ~/.cache/hyprlock-debug.log
exit $EXIT_CODE