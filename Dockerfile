FROM alpine:3.19

RUN apk add --no-cache bash curl ca-certificates tzdata

# Download Xray core
RUN mkdir -p /app/bin /app/config && \
    cd /tmp && \
    curl -fsSL -o xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -o xray.zip && \
    mv xray /app/bin/xray-linux-amd64 && \
    chmod +x /app/bin/xray-linux-amd64 && \
    rm -f /tmp/xray.zip

# Download geo data
RUN cd /app && \
    curl -fsSL -o geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat && \
    curl -fsSL -o geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

# Copy config
COPY config.json /app/config/config.json

WORKDIR /app

EXPOSE 2053

CMD ["/app/bin/xray-linux-amd64", "run", "-c", "/app/config/config.json"]
