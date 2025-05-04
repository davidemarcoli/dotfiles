#!/bin/bash
#
# Hyprland Lock Screen Recovery Script
# ------------------------------------
# This script helps recover from a crashed hyprlock session
# Run this from a TTY (Ctrl+Alt+F3) when your lock screen is stuck
#

# Terminal colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Hyprland Lock Screen Recovery Tool    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo

# Function to check if we're in a TTY
check_if_tty() {
    if [[ ! $(tty) =~ /dev/tty[0-9]+ ]]; then
        echo -e "${YELLOW}Warning: This script is designed to be run from a TTY.${NC}"
        echo -e "${YELLOW}For best results, press Ctrl+Alt+F3 and run this script there.${NC}"
        echo
        read -p "Continue anyway? (y/n): " choice
        if [[ ! "$choice" =~ ^[Yy]$ ]]; then
            echo "Exiting."
            exit 1
        fi
    fi
}

# Function to find active Hyprland sessions
find_hyprland_sessions() {
    local instances=()
    local sockets=()
    
    # Look for Hyprland socket files
    for socket in /run/user/*/hypr/*/.socket.sock; do
        if [[ -S "$socket" ]]; then
            instance=$(echo "$socket" | sed -E 's|/run/user/([^/]+)/hypr/([^/]+)/.socket.sock|\2|')
            instances+=("$instance")
            sockets+=("$socket")
        fi
    done
    
    echo "${instances[@]}"
}

# Main recovery function
recover_lock_screen() {
    echo -e "${BLUE}Step 1:${NC} Allowing session lock restore..."
    
    # Find active Hyprland sessions
    instances=($(find_hyprland_sessions))
    
    if [[ ${#instances[@]} -eq 0 ]]; then
        echo -e "${RED}Error: No active Hyprland sessions found.${NC}"
        echo "Make sure Hyprland is running."
        exit 1
    fi
    
    # For each Hyprland instance, try to restore lock
    for instance in "${instances[@]}"; do
        echo -e "  Attempting recovery for Hyprland instance: ${YELLOW}$instance${NC}"
        
        # Allow session lock restore
        if hyprctl --instance "$instance" keyword misc:allow_session_lock_restore 1 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Successfully allowed session lock restore for instance $instance"
        else
            echo -e "  ${RED}✗${NC} Failed to allow session lock restore for instance $instance"
        fi
    done
    
    echo
    echo -e "${BLUE}Step 2:${NC} Killing any running hyprlock processes..."
    
    # Try graceful kill first
    if pgrep -x "hyprlock" > /dev/null; then
        if pkill -x "hyprlock"; then
            echo -e "  ${GREEN}✓${NC} Successfully terminated hyprlock processes"
        else
            echo -e "  ${YELLOW}!${NC} Failed to terminate hyprlock, trying force kill..."
            if pkill -9 -x "hyprlock"; then
                echo -e "  ${GREEN}✓${NC} Successfully force-terminated hyprlock processes"
            else
                echo -e "  ${RED}✗${NC} Failed to force-terminate hyprlock processes"
            fi
        fi
    else
        echo -e "  ${YELLOW}!${NC} No hyprlock processes found to kill"
    fi
    
    echo
    echo -e "${GREEN}Recovery complete!${NC}"
    echo 
    echo -e "You can now:"
    echo -e "  1. ${YELLOW}Return to your Hyprland session${NC} (Ctrl+Alt+F1 or F2)"
    echo -e "  2. ${YELLOW}Start a new lock screen${NC} (Option below)"
    echo -e "  3. ${YELLOW}Reboot your system${NC} if issues persist"
    echo
    
    # Ask if they want to restart hyprlock
    read -p "Do you want to restart hyprlock now? (y/n): " restart_choice
    if [[ "$restart_choice" =~ ^[Yy]$ ]]; then
        echo "Restarting hyprlock..."
        
        for instance in "${instances[@]}"; do
            hyprctl --instance "$instance" dispatch exec hyprlock 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Successfully started hyprlock on instance $instance${NC}"
                break
            fi
        done
    else
        echo -e "Skipping hyprlock restart. You can manually restart it later."
    fi
    
    echo
    echo -e "${BLUE}Remember:${NC} To return to your graphical session, press ${YELLOW}Ctrl+Alt+F1${NC} or ${YELLOW}Ctrl+Alt+F2${NC}"
}

# Check if we're in a TTY
check_if_tty

# Run the recovery process
recover_lock_screen

exit 0