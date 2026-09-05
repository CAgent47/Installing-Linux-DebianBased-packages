FROM debian:trixie-backports

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