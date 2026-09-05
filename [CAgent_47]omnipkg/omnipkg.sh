#!/bin/bash

clear

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
MAGENTA=$(tput setaf 5)
BOLD=$(tput bold)
RESET=$(tput sgr0)
BPurple='\033[1;35m'
BGreen='\033[1;32m'
Yellow='\033[0;33m'
BRed='\033[1;31m'
BCyan='\033[1;36m'
BWhite='\033[1;37m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get sudo password once
echo -e "${CYAN} Please enter your sudo password:${RESET}"
echo -e "${YELLOW} [ WARNING ]: ${RESET}If you are root, do not enter a password and press Enter."
read -s -p "Password: " SUDO_PASS
echo ""
echo ""

# Function to run sudo commands with cached password
sudo_cmd() {
    echo "$SUDO_PASS" | sudo -S "$@" 2>/dev/null
}
export -f sudo_cmd
export SUDO_PASS

# Keep sudo alive in background
(while true; do echo "$SUDO_PASS" | sudo -S -v 2>/dev/null; sleep 100000; done) &
SUDO_KEEPALIVE_PID=$!

# Spinner function
spinner() {
    local pid=$1
    local msg=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r  ${CYAN}${spin:$i:1}${RESET} ${BWhite}$msg${RESET}"
        sleep 0.1
    done
    printf "\r  ${BGreen}✓${RESET} ${BWhite}$msg${RESET}\n"
}

# Progress bar function
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percent=$((current * 100 / total))
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    printf "\r  ${CYAN}[${RESET}"
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "${CYAN}]${RESET} ${BWhite}%3d%%${RESET}" "$percent"
}

# Animated header
clear
echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║${RESET}                                                                      "
echo -e "${CYAN}║${RESET}  ${BWHITE}██████╗ ███╗   ███╗███╗   ██╗██╗██████╗ ██╗  ██╗ ██████╗ "
echo -e "${CYAN}║${RESET}  ${BWHITE}██╔═══██╗████╗ ████║████╗  ██║██║██╔══██╗██║ ██╔╝██╔════╝ "
echo -e "${CYAN}║${RESET}  ${BWHITE}██║   ██║██╔████╔██║██╔██╗ ██║██║██████╔╝█████╔╝ ██║  ███╗"
echo -e "${CYAN}║${RESET}  ${BWHITE}██║   ██║██║╚██╔╝██║██║╚██╗██║██║██╔═══╝ ██╔═██╗ ██║   ██║"
echo -e "${CYAN}║${RESET}  ${BWHITE}╚██████╔╝██║ ╚═╝ ██║██║ ╚████║██║██║     ██║  ██╗╚██████╔╝"
echo -e "${CYAN}║${RESET}  ${BWHITE} ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝  ╚═╝ ╚═════╝"
echo -e "${CYAN}║${RESET}                                                                      "
echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${CYAN}║${RESET}  ${GREEN}🌟 Universal Package Bootstrapper${RESET}                   "
echo -e "${CYAN}║${RESET}  ${YELLOW}📌 v2.5.1${RESET}                                             "
echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${CYAN}║${RESET}  ${BLUE}🐧  Author   :${RESET} CAgent_47                              "
echo -e "${CYAN}║${RESET}  ${BLUE}📦  License  :${RESET} MIT                                   "
echo -e "${CYAN}║${RESET}  ${BLUE}🌐  GitHub   :${RESET} github.com/CAgent47                   "
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Update system
echo -e "${BCyan}▶  Updating system...${RESET}"
update_cmd=$(python3 "$SCRIPT_DIR/core/updatePKG.py" 2>/dev/null)
if [[ -n "$update_cmd" ]]; then
    # Remove sudo from command since well use our function
    update_cmd_clean=$(echo "$update_cmd" | sed 's/sudo //g')
    {
        echo "$SUDO_PASS" | sudo -S bash -c "$update_cmd_clean" 2>/dev/null
    } &
    spinner $! "Updating system packages..."
    echo -e "  ${BGreen}✓${RESET} System updated successfully\n"
else
    echo -e "  ${YELLOW}⚠${RESET} No update command found\n"
fi

# Install packages
echo -e "${BCyan}▶  Installing packages...${RESET}"
install_cmd=$(python3 "$SCRIPT_DIR/core/installPKG.py" 2>/dev/null)

if [[ -z "$install_cmd" ]]; then
    echo -e "  ${BRed}✗${RESET} ERROR: No install command found"
    kill $SUDO_KEEPALIVE_PID 2>/dev/null
    exit 1
fi

echo -e "  ${YELLOW}→${RESET} ${BWhite}$install_cmd${RESET}\n"

# Clean sudo from command
install_cmd_clean=$(echo "$install_cmd" | sed 's/sudo //g')

# Execute with progress
{
    echo "$SUDO_PASS" | sudo -S bash -c "$install_cmd_clean" 2>&1
} &

INSTALL_PID=$!

# Show simple progress dots
echo -n "  Installing"
while kill -0 $INSTALL_PID 2>/dev/null; do
    for dot in "." ".." "..."; do
        echo -ne "\r  Installing$dot"
        sleep 0.5
    done
done
echo -e "\r  ${BGreen}✓${RESET} Installation completed"

# Wait for actual exit status
wait $INSTALL_PID
INSTALL_STATUS=$?

if [[ $INSTALL_STATUS -eq 0 ]]; then
    echo -e "\n  ${BGreen}✓${RESET} All packages installed successfully!\n"
else
    echo -e "\n  ${BRed}✗${RESET} Installation failed\n"
    kill $SUDO_KEEPALIVE_PID 2>/dev/null
    exit 1
fi

# Clean system
echo -e "${BCyan}▶  Cleaning up...${RESET}"
clean_cmd=$(python3 "$SCRIPT_DIR/core/cleanPKG.py" 2>/dev/null)
if [[ -n "$clean_cmd" ]]; then
    clean_cmd_clean=$(echo "$clean_cmd" | sed 's/sudo //g')
    {
        echo "$SUDO_PASS" | sudo -S bash -c "$clean_cmd_clean" 2>/dev/null
    } &
    spinner $! "Cleaning system..."
    echo -e "  ${BGreen}✓${RESET} System cleaned successfully\n"
else
    echo -e "  ${YELLOW}⚠${RESET} No clean command found\n"
fi

# Kill sudo
kill $SUDO_KEEPALIVE_PID 2>/dev/null

# Final message
echo ""
echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${MAGENTA}║${RESET}                                                                     "
echo -e "${MAGENTA}║${RESET}  ${BWHITE}${RESET} ${GREEN}All tasks completed successfully!${RESET} "            
echo -e "${MAGENTA}║${RESET}                                                                      "
echo -e "${MAGENTA}║${RESET}  ${CYAN}${RESET} ${BWHITE}Your system is now ready to use!${RESET}"
echo -e "${MAGENTA}║${RESET}                                                                "
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════╝${RESET}"

echo ""
echo -e "${BCyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BGreen}    OmniPKG v2.5.1 - Made with   by CAgent_47${RESET}"
echo -e "${BCyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
