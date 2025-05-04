#!/bin/bash
# Hyprland Lock Screen Recovery Script

hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1'
hyprctl --instance 0 'dispatch exec hyprlock'