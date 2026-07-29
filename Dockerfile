FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl ca-certificates tzdata wget unzip \
    && rm -rf /var/lib/apt/lists/*

# Download 3x-ui
RUN cd /tmp && \
    wget -q https://github.com/MHSanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz && \
    tar -xzf x-ui-linux-amd64.tar.gz && \
    mv x-ui/x-ui /usr/local/bin/x-ui && \
    chmod +x /usr/local/bin/x-ui && \
    rm -rf x-ui x-ui-linux-amd64.tar.gz

# Download Xray core
RUN cd /tmp && \
    wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -o Xray-linux-64.zip && \
    chmod +x xray

# x-ui launches xray as: bin/xray-linux-amd64 (relative to WORKDIR)
# xray also writes config to bin/ (relative to its CWD = WORKDIR)
# So we need bin/ directory at WORKDIR with xray inside
WORKDIR /root
RUN mkdir -p /root/bin && \
    cp /tmp/xray /root/bin/xray-linux-amd64 && \
    chmod +x /root/bin/xray-linux-amd64 && \
    rm -f /tmp/xray /tmp/Xray-linux-64.zip

ENV XRAY_HIGH_LOGLEVEL=warning
EXPOSE 2053 2083 2087 2096 80 443

CMD ["x-ui"]
