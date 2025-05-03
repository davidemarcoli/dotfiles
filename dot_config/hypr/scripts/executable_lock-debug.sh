#!/bin/bash

# Debug information
echo "Starting lock screen at $(date)" >> ~/.cache/hyprlock-debug.log

# Launch lock screen
hyprlock -v >> ~/.cache/hyprlock-debug.log 2>&1 
exit_code=$?

# Log exit status
echo "Hyprlock exited with code $exit_code at $(date)" >> ~/.cache/hyprlock-debug.log