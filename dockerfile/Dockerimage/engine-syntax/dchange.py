import dockermadule

Dockerfile = """
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    bash \
    python3 \
    jq \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /omnipkg

COPY . /omnipkg/

RUN chmod +x omnipkg.sh

CMD ["./omnipkg.sh"]
"""

check_change = dockermadule.readDockerfile('docker-img/Dockerfile')
if dockermadule.exists('docker-img/Dockerfile'):
    if Dockerfile != check_change:
        print("sudo docker compose up --build")
    else:
        print("sudo docker compose up")
