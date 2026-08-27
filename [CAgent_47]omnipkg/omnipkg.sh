#!/bin/bash

clear 2>/dev/null

# Colors
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
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
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    CYAN=""
    MAGENTA=""
    BOLD=""
    RESET=""
    BPurple=""
    BGreen=""
    Yellow=""
    BRed=""
    BCyan=""
    BWhite=""
fi
# TODO: fix BSD bootstraper
# TODO: add python git curl installer for prerequisite

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SUDO_KEEPALIVE_PID=""

cleanup() {
    if [[ -n "$SUDO_KEEPALIVE_PID" ]]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
    fi
}
trap cleanup EXIT

run_pkg_cmd() {
    local cmd
    cmd=$(echo "$1" | sed 's/sudo //g')
    if [[ $EUID -eq 0 ]]; then
        bash -c "$cmd"
    elif [[ "$1" == *"sudo "* ]]; then
        sudo -n bash -c "$cmd"
    else
        bash -c "$cmd"
    fi
}

if [[ $EUID -ne 0 ]]; then
    echo -e "${CYAN} Sudo access is required for system package operations.${RESET}"
    if ! sudo -v; then
        echo -e "  ${BRed}✗${RESET} Sudo authentication failed"
        exit 1
    fi
    (while true; do sudo -n true 2>/dev/null; sleep 100; done) &
    SUDO_KEEPALIVE_PID=$!
fi

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
}

# Animated header
echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║${RESET}                                                                      "
echo -e "${CYAN}║${RESET}  ${BWHITE}██████╗ ███╗   ███╗███╗   ██╗██╗██████╗ ██╗  ██╗ ██████╗ "
echo -e "${CYAN}║${RESET}  ${BWHITE}██╔═══██╗████╗ ████║████╗  ██╗██║██╔══██╗██║ ██╔╝██╔════╝ "
echo -e "${CYAN}║${RESET}  ${BWHITE}██║   ██╗██╔████╔██║██╔██╗ ██║██║██████╔╝█████╔╝ ██║  ███╗"
echo -e "${CYAN}║${RESET}  ${BWHITE}██║   ██╗██║╚██╔╝██║██║╚██╗██║██║██╔═══╝ ██╔═██╗ ██║   ██║"
echo -e "${CYAN}║${RESET}  ${BWHITE}╚██████╔╝██║ ╚═╝ ██║██║ ╚████║██║██║     ██║  ██╗╚██████╔╝"
echo -e "${CYAN}║${RESET}  ${BWHITE} ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝  ╚═╝ ╚═════╝"
echo -e "${CYAN}║${RESET}                                                                      "
echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${CYAN}║${RESET}  ${GREEN}🌟 Universal Package Bootstrapper${RESET}                   "
echo -e "${CYAN}║${RESET}  ${YELLOW}📌 v2.4.0${RESET}                                             "
echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${CYAN}║${RESET}  ${BLUE}🐧  Author   :${RESET} CAgent_47                              "
echo -e "${CYAN}║${RESET}  ${BLUE}📦  License  :${RESET} MIT                                   "
echo -e "${CYAN}║${RESET}  ${BLUE}🌐  GitHub   :${RESET} github.com/CAgent47                   "
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Update system
echo -e "${BCyan}▶  Updating system...${RESET}"
update_cmd=$(python3 "$SCRIPT_DIR/core/updatePKG.py")
if [[ -n "$update_cmd" ]]; then
    {
        run_pkg_cmd "$update_cmd"
    } &
    spinner $! "Updating system packages..."
    wait $!
    UPDATE_STATUS=$?
    if [[ $UPDATE_STATUS -eq 0 ]]; then
        echo -e "  ${BGreen}✓${RESET} System updated successfully\n"
    else
        echo -e "  ${BRed}✗${RESET} System update failed\n"
        exit 1
    fi
else
    echo -e "  ${BRed}✗${RESET} ERROR: No update command found"
    exit 1
fi

# Install packages
echo -e "${BCyan}▶  Installing packages...${RESET}"
install_cmd=$(python3 "$SCRIPT_DIR/core/installPKG.py")

if [[ -z "$install_cmd" ]]; then
    echo -e "  ${BRed}✗${RESET} ERROR: No install command found"
    exit 1
fi

echo -e "  ${YELLOW}→${RESET} ${BWhite}$install_cmd${RESET}\n"

{
    run_pkg_cmd "$install_cmd"
} &

INSTALL_PID=$!

echo -n "  Installing"
while kill -0 $INSTALL_PID 2>/dev/null; do
    for dot in "." ".." "..."; do
        echo -ne "\r  Installing$dot"
        sleep 0.5
    done
done
echo -ne "\r                                \r"

wait $INSTALL_PID
INSTALL_STATUS=$?

if [[ $INSTALL_STATUS -eq 0 ]]; then
    echo -e "  ${BGreen}✓${RESET} All packages installed successfully!\n"
else
    echo -e "  ${BRed}✗${RESET} Installation failed\n"
    exit 1
fi

# Clean system
echo -e "${BCyan}▶  Cleaning up...${RESET}"
clean_cmd=$(python3 "$SCRIPT_DIR/core/cleanPKG.py")
if [[ -n "$clean_cmd" ]]; then
    {
        run_pkg_cmd "$clean_cmd"
    } &
    spinner $! "Cleaning system..."
    wait $!
    CLEAN_STATUS=$?
    if [[ $CLEAN_STATUS -eq 0 ]]; then
        echo -e "  ${BGreen}✓${RESET} System cleaned successfully\n"
    else
        echo -e "  ${BRed}✗${RESET} System cleanup failed (continuing)\n"
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} No clean command found\n"
fi

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
echo -e "${BGreen}    OmniPKG v2.0 - Made with   by CAgent_47${RESET}"
echo -e "${BCyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""