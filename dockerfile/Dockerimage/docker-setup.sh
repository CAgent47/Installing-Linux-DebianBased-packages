dockerInstaller() {
    if command -v docker.io &> /dev/null 2>&1; then
        eval $(python3 engine-syntax/autoremove.py)
    fi

    
}