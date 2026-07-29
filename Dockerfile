FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl ca-certificates tzdata wget \
    && rm -rf /var/lib/apt/lists/*

# Download 3x-ui binary
RUN mkdir -p /etc/x-ui /var/log/x-ui /etc/xray && \
    cd /tmp && \
    wget -q https://github.com/MHSanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz && \
    tar -xzf x-ui-linux-amd64.tar.gz && \
    mv x-ui/x-ui /usr/local/bin/x-ui && \
    chmod +x /usr/local/bin/x-ui && \
    rm -rf /tmp/x-ui*

# Download Xray core
RUN cd /tmp && \
    wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    apt-get install -y --no-install-recommends unzip && \
    unzip -o Xray-linux-64.zip -d /usr/local/share/xray && \
    chmod +x /usr/local/share/xray/xray && \
    ln -sf /usr/local/share/xray/xray /usr/bin/xray && \
    rm /tmp/Xray-linux-64.zip && \
    apt-get remove -y unzip && apt-get autoremove -y

ENV XRAY_HIGH_LOGLEVEL=warning

EXPOSE 2053 2083 2087 2096 80 443

CMD ["x-ui"]
