import os
import dockermadule

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

Dockerfile = r"""FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    bash \
    python3 \
    sudo \
    jq \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /omnipkg

COPY . /omnipkg/

RUN chmod +x omnipkg.sh

CMD ["./omnipkg.sh"]
"""

DOCKERFILE_PATH = os.path.join(BASE_DIR, '..', 'docker-img', 'Dockerfile')

if dockermadule.exists(DOCKERFILE_PATH):
    check_change = dockermadule.readDockerfile(DOCKERFILE_PATH)
    if Dockerfile != check_change:
        print(dockermadule.commandPrefix() + " docker compose up --build -d")
    else:
        print(dockermadule.commandPrefix() + " docker compose up -d")
else:
    print(dockermadule.commandPrefix() + " docker compose up --build -d")