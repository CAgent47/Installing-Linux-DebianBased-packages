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

# ---------- IF ROOT USER ----------
if [[ "$EUID" -eq 0 ]]; then
    IS_ROOT=true
    SUDO_PASS=""
    echo -e "${GREEN}[ INFO ]${RESET} Running as root, skipping sudo authentication.\n"
else
    IS_ROOT=false
    echo -e "${CYAN} Please enter your sudo password:${RESET}"
    read -s -p "Password: " SUDO_PASS
    echo ""
    echo ""

    # Keep sudo alive in background
    (while true; do echo "$SUDO_PASS" | sudo -S -v 2>/dev/null; sleep 100; done) &
    SUDO_KEEPALIVE_PID=$!
fi

# ---------- Secure Execute Command with sudo or without sudo ----------
run_privileged() {
    local cmd="$1"
    local cmd_clean
    cmd_clean=$(echo "$cmd" | sed 's/sudo //g')

    if [[ "$IS_ROOT" == true ]]; then
        bash -c "$cmd_clean"
    else
        echo "$SUDO_PASS" | sudo -S bash -c "$cmd_clean" 2>/dev/null
    fi
}

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

# Animated header
echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║${RESET}                                                                      "
echo -e "${CYAN}║${RESET}  ${BWhite}██████╗ ███╗   ███╗███╗   ██╗██╗██████╗ ██╗  ██╗ ██████╗ "
echo -e "${CYAN}║${RESET}  ${BWhite}██╔═══██╗████╗ ████║████╗  ██║██║██╔══██╗██║ ██╔╝██╔════╝ "
echo -e "${CYAN}║${RESET}  ${BWhite}██║   ██║██╔████╔██║██╔██╗ ██║██║██████╔╝█████╔╝ ██║  ███╗"
echo -e "${CYAN}║${RESET}  ${BWhite}██║   ██║██║╚██╔╝██║██║╚██╗██║██║██╔═══╝ ██╔═██╗ ██║   ██║"
echo -e "${CYAN}║${RESET}  ${BWhite}╚██████╔╝██║ ╚═╝ ██║██║ ╚████║██║██║     ██║  ██╗╚██████╔╝"
echo -e "${CYAN}║${RESET}  ${BWhite} ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝  ╚═╝ ╚═════╝"
echo -e "${CYAN}║${RESET}                                                                      "
echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${CYAN}║${RESET}  ${GREEN}🌟 Universal Package Bootstrapper${RESET}                   "
echo -e "${CYAN}║${RESET}  ${YELLOW}📌 v2.0${RESET}                                             "
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
    { run_privileged "$update_cmd"; } &
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
    [[ "$IS_ROOT" == false ]] && kill $SUDO_KEEPALIVE_PID 2>/dev/null
    exit 1
fi

echo -e "  ${YELLOW}→${RESET} ${BWhite}$install_cmd${RESET}\n"

{ run_privileged "$install_cmd"; } &
INSTALL_PID=$!

echo -n "  Installing"
while kill -0 $INSTALL_PID 2>/dev/null; do
    for dot in "." ".." "..."; do
        echo -ne "\r  Installing$dot"
        sleep 0.5
    done
done
echo -e "\r  ${BGreen}✓${RESET} Installation completed"

wait $INSTALL_PID
INSTALL_STATUS=$?

if [[ $INSTALL_STATUS -eq 0 ]]; then
    echo -e "\n  ${BGreen}✓${RESET} All packages installed successfully!\n"
else
    echo -e "\n  ${BRed}✗${RESET} Installation failed\n"
    [[ "$IS_ROOT" == false ]] && kill $SUDO_KEEPALIVE_PID 2>/dev/null
    exit 1
fi

# Clean system
echo -e "${BCyan}▶  Cleaning up...${RESET}"
clean_cmd=$(python3 "$SCRIPT_DIR/core/cleanPKG.py" 2>/dev/null)
if [[ -n "$clean_cmd" ]]; then
    { run_privileged "$clean_cmd"; } &
    spinner $! "Cleaning system..."
    echo -e "  ${BGreen}✓${RESET} System cleaned successfully\n"
else
    echo -e "  ${YELLOW}⚠${RESET} No clean command found\n"
fi

[[ "$IS_ROOT" == false ]] && kill $SUDO_KEEPALIVE_PID 2>/dev/null

# Final message
echo ""
echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${MAGENTA}║${RESET}  ${GREEN}All tasks completed successfully!${RESET}"
echo -e "${MAGENTA}║${RESET}  ${BWhite}Your system is now ready to use!${RESET}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════╝${RESET}"

echo ""
echo -e "${BCyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BGreen}    OmniPKG v2.0 - Made by CAgent_47${RESET}"
echo -e "${BCyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""