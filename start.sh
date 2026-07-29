#!/bin/sh
# Ensure bin/ exists at CWD and has xray
CWD=$(pwd)
mkdir -p "$CWD/bin"
cp /app/bin/xray-linux-amd64 "$CWD/bin/xray-linux-amd64" 2>/dev/null
chmod +x "$CWD/bin/xray-linux-amd64" 2>/dev/null

# Copy geo data to CWD
cp /app/geoip.dat "$CWD/" 2>/dev/null
cp /app/geosite.dat "$CWD/" 2>/dev/null

exec /app/x-ui
