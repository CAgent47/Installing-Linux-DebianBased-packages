FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    bash \
    python3 \
    jq \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY . /

RUN chmod +x omnipkg.sh

CMD ["./omnipkg.sh"]