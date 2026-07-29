FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install 3x-ui
RUN mkdir -p /etc/x-ui /var/log/x-ui && \
    curl -fsSL https://github.com/MHSanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz -o /tmp/x-ui.tar.gz && \
    tar -xzf /tmp/x-ui.tar.gz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/x-ui && \
    rm /tmp/x-ui.tar.gz

ENV XRAY_HIGH_LOGLEVEL=warning
ENV XRAY_SUB_PATH=sub

EXPOSE 2053 2083 2087 2096 80 443

CMD ["x-ui"]
