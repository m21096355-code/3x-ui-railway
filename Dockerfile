FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl ca-certificates tzdata wget unzip \
    && rm -rf /var/lib/apt/lists/*

# Download 3x-ui binary
RUN mkdir -p /etc/x-ui /var/log/x-ui /etc/xray /app/bin && \
    cd /tmp && \
    wget -q https://github.com/MHSanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz && \
    tar -xzf x-ui-linux-amd64.tar.gz && \
    mv x-ui/x-ui /usr/local/bin/x-ui && \
    chmod +x /usr/local/bin/x-ui && \
    rm -rf /tmp/x-ui*

# Download Xray core - put where 3x-ui expects it
RUN cd /tmp && \
    wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -o Xray-linux-64.zip && \
    mv xray /app/bin/xray-linux-amd64 && \
    chmod +x /app/bin/xray-linux-amd64 && \
    rm /tmp/Xray-linux-64.zip

WORKDIR /app

ENV XRAY_HIGH_LOGLEVEL=warning

EXPOSE 2053 2083 2087 2096 80 443

CMD ["x-ui"]
