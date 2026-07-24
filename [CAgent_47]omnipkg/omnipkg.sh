#!/bin/bash

clear

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
BPurple='\033[1;35m'
BGreen='\033[1;32m'
Yellow='\033[0;33m'
BRed='\033[1;31m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Simple installer function - WITHOUT set -e
installer() {
    local pkg="$1"
    
    # Check if already installed
    if command -v "$pkg" &> /dev/null; then
        echo -e "${Yellow}[ WARNING ]${RESET} $pkg is already installed."
        return 0
    fi
    
    echo -e "${BGreen}[ Install ]${RESET} Installing $pkg ..."
    
    # Get install command from Python
    local install_cmd
    install_cmd=$(python3 "$SCRIPT_DIR/core/installPKG.py" "$pkg" 2>/dev/null)
    
    if [[ -z "$install_cmd" ]]; then
        echo -e "${BRed}[ ERROR ]${RESET} No install command found for $pkg"
        return 1
    fi
    
    echo -e "${CYAN}[ DEBUG ]${RESET} Running: $install_cmd"
    
    # Execute the command DIRECTLY
    eval "$install_cmd"
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${BGreen}[ SUCCESS ]${RESET} $pkg installed successfully!"
        return 0
    else
        echo -e "${BRed}[ ERROR ]${RESET} Failed to install $pkg (exit: $exit_code)"
        return 1
    fi
}

# Header
echo "${CYAN}============================================"
echo "  ██████╗ ███╗   ███╗███╗   ██╗██╗██████╗ ██╗  ██╗ ██████╗ "
echo "  ██╔═══██╗████╗ ████║████╗  ██║██║██╔══██╗██║ ██╔╝██╔════╝ "
echo "  ██║   ██║██╔████╔██║██╔██╗ ██║██║██████╔╝█████╔╝ ██║  ███╗"
echo "  ██║   ██║██║╚██╔╝██║██║╚██╗██║██║██╔═══╝ ██╔═██╗ ██║   ██║"
echo "  ╚██████╔╝██║ ╚═╝ ██║██║ ╚████║██║██║     ██║  ██╗╚██████╔╝"
echo "   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ "
echo "============================================"
echo "${GREEN}          Universal Package Bootstrapper     ${RESET}"
echo "${YELLOW}                  v1.7                       ${RESET}"
echo "============================================"
echo "  ${BLUE}🐧  Author   :${RESET} CAgent_47"
echo "  ${BLUE}📦  License  :${RESET} MIT                          "
echo "  ${BLUE}🌐  GitHub   :${RESET} github.com/CAgent47"
echo "============================================"
echo ""
echo "  ${GREEN}[ INFO ]${RESET} Starting OmniPKG Package Installer..."
echo "  ${GREEN}[ INFO ]${RESET} Detecting your system and package manager..."
echo "${RESET}"

sleep 2

# Check and create JSON files
echo "============================================"
echo "${GREEN}[ INFO ]${RESET} Checking JSON files..."
python3 "$SCRIPT_DIR/core/createJson.py"
if [[ $? -ne 0 ]]; then
    echo -e "${BRed}[ ERROR ]${RESET} Failed to create JSON files"
    exit 1
fi
echo -e "${GREEN}[ OK ]${RESET} JSON files created/updated successfully"

# Update system
echo "============================================"
echo -e "${BPurple}[ UPDATE ]${RESET} Updating your system....."
update_cmd=$(python3 "$SCRIPT_DIR/core/updatePKG.py" 2>/dev/null)
if [[ -n "$update_cmd" ]]; then
    echo -e "${CYAN}[ DEBUG ]${RESET} Running: $update_cmd"
    eval "$update_cmd"
    if [[ $? -ne 0 ]]; then
        echo -e "${YELLOW}[ WARNING ]${RESET} System update failed, continuing..."
    fi
else
    echo -e "${YELLOW}[ WARNING ]${RESET} No update command found"
fi

# Install jq first
echo "============================================"
echo -e "${BGreen}[ Install ]${RESET} Checking Jq...."
installer jq
if [[ $? -ne 0 ]]; then
    echo -e "${BRed}[ ERROR ]${RESET} Failed to install jq, which is required"
    exit 1
fi

# Detect packages to install
echo "============================================"
echo -e "${BGreen}[ Install ]${RESET} Detecting Packages"

# Get packages list
mapfile -t Packages < <(python3 "$SCRIPT_DIR/core/detectPKG.py" 2>/dev/null)
if [[ $? -ne 0 ]] || [[ ${#Packages[@]} -eq 0 ]]; then
    echo -e "${YELLOW}[ INFO ]${RESET} No packages to install or detection failed"
    exit 0
fi

echo " "
echo -e "${Yellow}[ WARNING ]${RESET} The following packages will be installed:"
for showPKG in "${Packages[@]}"; do
    echo -e "  ${CYAN}•${RESET} $showPKG"
done

echo " "
echo -e "${YELLOW}Do you want to install these packages? (y/n)${RESET}"
read -r InstallREQ

if [[ "$InstallREQ" =~ ^[Yy]$ ]]; then
    echo -e "${BGreen}[ OK ]${RESET} Installing Packages. Please wait..."
    echo ""
    
    failed_packages=()
    success_packages=()
    
    for package in "${Packages[@]}"; do
        if installer "$package"; then
            success_packages+=("$package")
        else
            failed_packages+=("$package")
        fi
        echo "----------------------------------------"
    done
    
    # Show installation summary
    echo "============================================"
    echo -e "${BGreen}[ SUMMARY ]${RESET} Installation complete"
    echo -e "${GREEN}[ SUCCESS ]${RESET} Installed: ${#success_packages[@]} packages"
    if [[ ${#success_packages[@]} -gt 0 ]]; then
        for pkg in "${success_packages[@]}"; do
            echo -e "  ${GREEN}✓${RESET} $pkg"
        done
    fi
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        echo -e "${BRed}[ ERROR ]${RESET} Failed to install: ${#failed_packages[@]} packages"
        for pkg in "${failed_packages[@]}"; do
            echo -e "  ${BRed}✗${RESET} $pkg"
        done
    fi
    
    # Clean up
    echo "============================================"
    echo -e "${BGreen}[ CLEAN ]${RESET} Cleaning up..."
    clean_cmd=$(python3 "$SCRIPT_DIR/core/cleanPKG.py" 2>/dev/null)
    if [[ -n "$clean_cmd" ]]; then
        echo -e "${CYAN}[ DEBUG ]${RESET} Running: $clean_cmd"
        eval "$clean_cmd"
        if [[ $? -ne 0 ]]; then
            echo -e "${YELLOW}[ WARNING ]${RESET} Cleanup failed"
        fi
    fi
    
else
    echo -e "${YELLOW}[ INFO ]${RESET} Edit packages in core/packages.json"
fi

echo "============================================"
echo -e "${GREEN}[ DONE ]${RESET} Script finished!"