FROM debian:bookworm

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