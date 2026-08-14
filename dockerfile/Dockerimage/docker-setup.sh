python3 engine-syntax/createJson.py
CONTAINER_NAME=$(sudo docker ps --format "{{.Names}}" | grep -i omnipkg)
dockerInstaller() {
    if command -v docker.io &> /dev/null 2>&1; then
        eval $(python3 engine-syntax/autoremove.py)
    fi
    eval $(python3 engine-syntax/setup-Repostory.py)
    eval $(python3 engine-syntax/install.py)
}

if command -v docker &> /dev/null 2>&1; then
    echo "[ Docker ]: Docker Is Ready"
else
    dockerInstaller
fi

if [[ "$CONTAINER_NAME" ]]; then
        echo "tsk container is working; stoping tsk container"
        sudo docker compose down
        echo "Running Please Wait a moment"
        eval $(python3 engine-syntax/dchange.py)
        echo "Contanier Activated Run your browser"
    else
        echo "Running Please Wait a moment"
        eval $(python3 engine-syntax/dchange.py)
        echo "Contanier Activated Run your browser"
fi