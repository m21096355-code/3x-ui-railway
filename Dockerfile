FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl ca-certificates tzdata wget unzip \
    && rm -rf /var/lib/apt/lists/*

# Download 3x-ui + Xray
RUN cd /tmp && \
    wget -q https://github.com/MHSanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz && \
    tar -xzf x-ui-linux-amd64.tar.gz && \
    mv x-ui/x-ui /usr/local/bin/x-ui && \
    chmod +x /usr/local/bin/x-ui && \
    rm -rf x-ui x-ui-linux-amd64.tar.gz && \
    wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -o Xray-linux-64.zip && \
    chmod +x xray && \
    mkdir -p bin && \
    cp xray bin/xray-linux-amd64 && \
    rm Xray-linux-64.zip

# x-ui looks for bin/xray-linux-amd64 relative to /bin, /app/bin, and WORKDIR
RUN mkdir -p /app/bin /bin && \
    cp /tmp/xray /app/bin/xray-linux-amd64 2>/dev/null; \
    cp /tmp/xray /bin/xray-linux-amd64 2>/dev/null; \
    cp /tmp/xray /usr/local/bin/xray 2>/dev/null; \
    true

# Find xray from where we downloaded it  
WORKDIR /root

ENV XRAY_HIGH_LOGLEVEL=warning
EXPOSE 2053 2083 2087 2096 80 443

CMD ["x-ui"]
