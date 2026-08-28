SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

python3 engine-syntax/createJson.py

if [[ $EUID -eq 0 ]]; then
    DOCKER_PREFIX=""
else
    DOCKER_PREFIX="sudo"
fi

dockerInstaller() {
    AUTOREMOVE_CMD=$(python3 engine-syntax/autoremove.py) || AUTOREMOVE_CMD=""
    if [[ -n "$AUTOREMOVE_CMD" ]]; then
        eval "$AUTOREMOVE_CMD" || true
    fi
    SETUP_CMD=$(python3 engine-syntax/setup-Repostory.py) || { echo "[ Docker ]: No supported package manager for Docker install"; exit 1; }
    eval "$SETUP_CMD"
    INSTALL_CMD=$(python3 engine-syntax/install.py) || { echo "[ Docker ]: Failed to build install command"; exit 1; }
    eval "$INSTALL_CMD"
}

if command -v docker &> /dev/null; then
    echo "[ Docker ]: Docker Is Ready"
else
    dockerInstaller
fi

CONTAINER_NAME=$($DOCKER_PREFIX docker ps --format "{{.Names}}" 2>/dev/null | grep -i omnipkg)

if [[ -n "$CONTAINER_NAME" ]]; then
    echo "[ Docker ]: Container is running; stopping container"
    $DOCKER_PREFIX docker compose down
fi

echo "[ Docker ]: Running Please Wait a moment"
eval "$(python3 engine-syntax/dchange.py)"
echo "[ Docker ]: Container Activated"