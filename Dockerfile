FROM alpine:3.18

RUN apk add --no-cache bash curl tzdata

# Install 3x-ui
RUN mkdir -p /etc/x-ui /var/log/x-ui && \
    curl -fsSL https://github.com/MHSanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz -o /tmp/x-ui.tar.gz && \
    tar -xzf /tmp/x-ui.tar.gz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/x-ui && \
    rm /tmp/x-ui.tar.gz

ENV XRAY_HIGH_LOGLEVEL=warning
ENV XRAY_SUB_PATH=sub
ENV TZ=Europe/Amsterdam

EXPOSE 2053 2083 2087 2096 80 443

CMD ["x-ui"]
