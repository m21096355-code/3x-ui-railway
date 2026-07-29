FROM alpine:3.19

ENV TZ=Europe/Amsterdam
ENV XUI_IN_DOCKER=true

RUN apk add --no-cache bash curl ca-certificates tzdata openssl

# Download 3x-ui release
RUN mkdir -p /app/bin && \
    cd /tmp && \
    curl -fsSL -o x-ui.tar.gz https://github.com/MHSanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz && \
    tar -xzf x-ui.tar.gz && \
    mv x-ui/x-ui /app/x-ui && \
    chmod +x /app/x-ui && \
    rm -rf /tmp/x-ui*

# Download Xray core into /app/bin/
RUN cd /tmp && \
    curl -fsSL -o xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -o xray.zip && \
    mv xray /app/bin/xray-linux-amd64 && \
    chmod +x /app/bin/xray-linux-amd64 && \
    rm -f /tmp/xray.zip /tmp/geoip.dat /tmp/geosite.dat

# Download geo data
RUN cd /app && \
    curl -fsSL -o geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat && \
    curl -fsSL -o geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

# Startup script: ensure bin/ exists at CWD
COPY start.sh /start.sh
RUN chmod +x /start.sh /app/x-ui /app/bin/xray-linux-amd64

WORKDIR /app

EXPOSE 2053

ENTRYPOINT ["/start.sh"]
