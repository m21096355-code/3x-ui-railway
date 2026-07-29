#!/bin/bash
# startup script for 3x-ui on Railway
# x-ui expects xray at bin/xray-linux-amd64 relative to CWD
# xray also writes config to bin/ relative to CWD
# So we ensure bin/ exists at CWD and has xray

mkdir -p bin
cp /usr/local/bin/xray-core bin/xray-linux-amd64 2>/dev/null || \
cp /root/bin/xray-linux-amd64 bin/xray-linux-amd64 2>/dev/null || \
cp /usr/local/bin/xray bin/xray-linux-amd64 2>/dev/null || \
cp /usr/bin/xray bin/xray-linux-amd64 2>/dev/null || \
cp /tmp/xray bin/xray-linux-amd64 2>/dev/null || true

chmod +x bin/xray-linux-amd64 2>/dev/null || true

# Start x-ui
exec x-ui
